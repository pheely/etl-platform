# ETL Project

## Create a virtual environment

```bash
python -m venv my_env
```

## Run Tests

Make sure the `my_env` virtual enviornment exists.

```bash
source my_env/bin/activate
pip install pytest pyspark
cd tests
pytest test_main.py -s
```

## Run Locally

```bash
python src/main.py \
  --input "$(pwd)/data/names.csv" \
  --output "$(pwd)/data/output_last_names" \
  --input_format csv \
  --write_mode overwrite
```

## Build

```bash
./build.sh
```

## Upload Test Data

```bash
gsutil cp data/names.csv gs://py-service-01-etl-input
```

## Submit a Dataproc Batch Job

```bash
./run.sh
```

