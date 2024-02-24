#!/usr/bin/python3

import argparse
import boto3
import datetime
import os
import time
import _config
import subprocess

parser = argparse.ArgumentParser(description='Clean a folder')
parser.add_argument('--folder_path', type=str, help='The folder to clean')
parser.add_argument('--s3_path', type=str, nargs='?', help='The S3 path to upload to')
args = parser.parse_args()

GZIP_TMP = '/tmp/XZRTVJAEZFPKYWTTXDESUPEAYLSLNLUP'

folder_path = args.folder_path
now_ts = time.time()
timeout_ts = now_ts - 3600 * 24 * 7  # 7 days

s3_path = args.s3_path

# Get files in folder
file_path_list = os.listdir(folder_path)
file_path_list = [os.path.join(folder_path, file_path) for file_path in file_path_list]

# Filter files outdated
file_path_list = [file_path for file_path in file_path_list if os.path.getmtime(file_path) < timeout_ts]

s3 = boto3.client('s3')

# Process files outdated
for file_path in file_path_list:
    print(f"Archive clean {file_path} START")

    file_mtime_ts = os.path.getmtime(file_path)
    file_mtime_dt = datetime.datetime.fromtimestamp(file_mtime_ts)
    file_mtime_yyyy = file_mtime_dt.strftime('%Y')
    file_mtime_mm = file_mtime_dt.strftime('%m')

    basename = os.path.basename(file_path)

    if s3_path != None:
        print('Compressing...')
        subprocess.run(['gzip', '-c', file_path], stdout=open(GZIP_TMP, 'wb'), check=True)

        print('Uploading to S3...')
        s3.upload_file(GZIP_TMP, _config.S3_BUCKET, f'archive/{s3_path}/{file_mtime_yyyy}/{file_mtime_mm}/{basename}.gz')

        print('Removing temporary file...')
        os.remove(GZIP_TMP)

    print('Removing local file...')
    os.remove(file_path)

    print(f"Archive clean {file_path} END")
