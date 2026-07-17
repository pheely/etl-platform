import os
import sys
sys.path.insert(
    0, os.path.abspath(os.path.join(os.path.dirname(__file__), "../src"))
)

import argparse
import pytest
from unittest.mock import patch, MagicMock
from pyspark.sql import SparkSession
import main  # Assumes your file is named main.py


@pytest.fixture(scope="session")
def spark_session():
    """Provides a local Spark session for testing DataFrame logic."""
    spark = (
        SparkSession.builder.master("local[2]")
        .appName("pytest-spark-testing")
        .config("spark.sql.shuffle.partitions", "1")
        .getOrCreate()
    )
    yield spark
    spark.stop()


# ==========================================
# Unit Tests for parse_args and validation
# ==========================================


def test_parse_args_success():
    """Tests that valid arguments are parsed correctly."""
    test_args = [
        "main.py",
        "--input",
        "gs://bucket/input.csv",
        "--output",
        "gs://bucket/output",
        "--write_mode",
        "overwrite",
        "--input_format",
        "csv",
    ]

    with patch("sys.argv", test_args):
        args = main.parse_args()
        assert args.input == "gs://bucket/input.csv"
        assert args.output == "gs://bucket/output"
        assert args.write_mode == "overwrite"
        assert args.input_format == "csv"


def test_parse_args_missing_required():
    """Tests that missing required arguments raises a SystemExit."""
    test_args = ["main.py", "--input", "gs://bucket/input.csv"]

    with patch("sys.argv", test_args):
        with pytest.raises(SystemExit):
            main.parse_args()


def test_validate_required_path_success():
    """Tests that validation passes with correct strings."""
    # Should not raise any exception
    main._validate_required_path("--input", "gs://bucket/path")


@pytest.mark.parametrize("invalid_value", [None, "", "   "])
def test_validate_required_path_failures(invalid_value):
    """Tests that empty, whitespace, or None values trigger a ValueError."""
    with pytest.raises(ValueError) as excinfo:
        main._validate_required_path("--input", invalid_value)
    assert "--input is required" in str(excinfo.value)


# ==========================================
# Integration/Functional Tests for main()
# ==========================================


@patch("main.SparkSession")
@patch("main.parse_args")
def test_main_execution_flow(mock_parse_args, mock_spark_session_builder):
    """Mocks Spark to verify the end-to-end execution flow inside main()."""
    # 1. Setup mocked arguments
    mock_args = argparse.Namespace(
        input="gs://mock-input",
        output="gs://mock-output",
        write_mode="append",
        input_format="csv",
        temp_gcs_bucket=None,
    )
    mock_parse_args.return_value = mock_args

    # 2. Setup Spark Mocks
    mock_spark = MagicMock()
    mock_spark_session_builder.builder.appName.return_value.getOrCreate.return_value = (
        mock_spark
    )

    # Mock the reader chain: spark.read.option().option().csv()
    mock_df = MagicMock()
    (
        mock_spark.read.option.return_value.option.return_value.csv.return_value
    ) = mock_df

    # Mock the writer chain: df.select().coalesce().write.mode().option().csv()
    mock_selected_df = MagicMock()
    mock_df.select.return_value = mock_selected_df

    mock_writer = MagicMock()
    (
        mock_selected_df.coalesce.return_value.write.mode.return_value.option.return_value.csv
    ) = mock_writer

    # 3. Execute main
    main.main()

    # 4. Verifications
    # Get the mock that actually receives the .csv() call at the end of the chain
    mock_option_1 = mock_spark.read.option
    mock_option_2 = mock_option_1.return_value.option

    # Verify both sequential option calls
    mock_option_1.assert_called_with("header", "true")
    mock_option_2.assert_called_with("inferSchema", "true")

    # Verify the final .csv call
    mock_option_2.return_value.csv.assert_called_once_with("gs://mock-input")

    mock_df.select.assert_called_once_with("last_name")
    mock_selected_df.coalesce.assert_called_once_with(1)
    (
        mock_selected_df.coalesce.return_value.write.mode.assert_called_once_with(
            "append"
        )
    )
    mock_spark.stop.assert_called_once()


def test_spark_data_transformation(spark_session, tmp_path):
    """Uses a real local Spark session to verify that 'last_name' is successfully filtered."""
    # 1. Create a dummy local CSV input file
    input_dir = tmp_path / "input"
    input_dir.mkdir()
    input_file = input_dir / "data.csv"
    input_file.write_text("first_name,last_name\nJohn,Doe\nJane,Smith")

    output_dir = tmp_path / "output"

    # 2. Mock parse_args to supply our local temp paths instead of GCS paths
    mock_args = argparse.Namespace(
        input=str(input_file),
        output=str(output_dir),
        write_mode="overwrite",
        input_format="csv",
        temp_gcs_bucket=None,
    )

    with patch("main.parse_args", return_value=mock_args), patch(
        "main.SparkSession.builder"
    ) as mock_builder:

        # Force the main script to use our already running test Spark session
        mock_builder.appName.return_value.getOrCreate.return_value = (
            spark_session
        )

        # Prevent spark.stop() from tearing down our test fixture session prematurely
        with patch.object(spark_session, "stop"):
            main.main()

    # 3. Read back the generated output data to verify correct schema/content
    result_df = spark_session.read.option("header", "true").csv(
        str(output_dir)
    )

    assert "last_name" in result_df.columns
    assert "first_name" not in result_df.columns

    rows = result_df.collect()
    assert len(rows) == 2
    assert rows[0]["last_name"] == "Doe"
    assert rows[1]["last_name"] == "Smith"