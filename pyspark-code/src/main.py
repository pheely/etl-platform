import argparse
from pyspark.sql import SparkSession


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Read data from GCS and write last names to an output file using Spark."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="GCS path to input data, e.g., gs://your-bucket/input/*.csv"
    )
    parser.add_argument(
        "--output",
        required=True,
        help="GCS path for the extracted last names, e.g., gs://your-bucket/output/last_names"
    )
    parser.add_argument(
        "--write_mode",
        default="append",
        choices=["append", "overwrite", "ignore", "errorifexists"],
        help="Output write mode"
    )
    parser.add_argument(
        "--input_format",
        default="csv",
        choices=["csv", "json", "parquet"],
        help="Input data format"
    )
    parser.add_argument(
        "--temp_gcs_bucket",
        required=False,
        help="Optional temporary GCS bucket for intermediate data storage, e.g., gs://your-temp-bucket"
    )
    return parser.parse_args()


def _validate_required_path(name: str, value: str) -> None:
    if value is None or value.strip() == "":
        raise ValueError(f"{name} is required but was not provided.")


def main() -> None:
    args = parse_args()

    # Validate required paths
    _validate_required_path("--input", args.input)
    _validate_required_path("--output", args.output)

    # Initialize Spark
    spark = SparkSession.builder.appName("extract-last-names-job-py").getOrCreate()

    reader = spark.read
    if args.input_format == "csv":
        df = (
            reader.option("header", "true")
            .option("inferSchema", "true")
            .csv(args.input)
        )
    elif args.input_format == "json":
        df = reader.json(args.input)

    print(f"args.output: {args.output}")

    last_names_df = df.select("last_name")
    {
        last_names_df.coalesce(1)
        .write.mode(args.write_mode)
        .option("header", "true")
        .csv(args.output)
    }

    spark.stop()


if __name__ == "__main__":
    main()
