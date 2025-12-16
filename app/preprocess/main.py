import os
import pandas as pd
import boto3

S3_ENDPOINT = os.getenv("S3_ENDPOINT", "http://minio.storage.svc.cluster.local:9000")
S3_ACCESS_KEY = os.getenv("S3_ACCESS_KEY", "minioadmin")
S3_SECRET_KEY = os.getenv("S3_SECRET_KEY", "minioadmin")

RAW_BUCKET = os.getenv("RAW_BUCKET", "raw-data")
RAW_KEY = os.getenv("RAW_KEY", "input.csv")
OUT_BUCKET = os.getenv("OUT_BUCKET", "processed-data")
OUT_KEY = os.getenv("OUT_KEY", "clean.csv")

s3 = boto3.client(
    "s3",
    endpoint_url=S3_ENDPOINT,
    aws_access_key_id=S3_ACCESS_KEY,
    aws_secret_access_key=S3_SECRET_KEY,
)

def main():
    obj = s3.get_object(Bucket=RAW_BUCKET, Key=RAW_KEY)
    df = pd.read_csv(obj["Body"])

    df_clean = df.dropna()
    s3.put_object(
        Bucket=OUT_BUCKET,
        Key=OUT_KEY,
        Body=df_clean.to_csv(index=False).encode("utf-8"),
        ContentType="text/csv",
    )

    print(f"Wrote s3://{OUT_BUCKET}/{OUT_KEY} rows={len(df_clean)}")

if __name__ == "__main__":
    main()
