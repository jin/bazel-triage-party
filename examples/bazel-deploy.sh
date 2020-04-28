#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eux

# Export this environment variable before running this script
echo "token path: ${GITHUB_TOKEN_PATH}"

export PROJECT=di-cloud-exp
export IMAGE=gcr.io/di-cloud-exp/triage-party
export SERVICE_NAME=teaparty
export CONFIG_FILE=examples/bazel.yaml

env DOCKER_BUILDKIT=1 docker build \
  -t "${IMAGE}" \
  --build-arg "CFG=${CONFIG_FILE}" \
  --secret "id=github,src=${GITHUB_TOKEN_PATH}" .

docker push "${IMAGE}" || exit 2

readonly token="$(cat ${GITHUB_TOKEN_PATH})"

gcloud beta run deploy "${SERVICE_NAME}" \
    --project "${PROJECT}" \
    --image "${IMAGE}" \
    --set-env-vars="GITHUB_TOKEN=${token}" \
    --allow-unauthenticated \
    --region us-central1 \
    --max-instances 2 \
    --memory 384Mi \
    --platform managed
