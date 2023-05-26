/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


# [START aiplatform_create_dataset_image_sample]
resource "google_vertex_ai_dataset" "image_dataset" {
  display_name        = "image-dataset"
  metadata_schema_uri = "gs://google-cloud-aiplatform/schema/dataset/metadata/image_1.0.0.yaml"
  region              = "us-central1"
}
# [END aiplatform_create_dataset_image_sample]

# [START aiplatform_create_dataset_tabular_sample]
resource "google_vertex_ai_dataset" "tabular_dataset" {
  display_name        = "tabular-dataset"
  metadata_schema_uri = "gs://google-cloud-aiplatform/schema/dataset/metadata/tabular_1.0.0.yaml"
  region              = "us-central1"
}
# [END aiplatform_create_dataset_tabular_sample]

# [START aiplatform_create_dataset_text_sample]
resource "google_vertex_ai_dataset" "text_dataset" {
  display_name        = "text-dataset"
  metadata_schema_uri = "gs://google-cloud-aiplatform/schema/dataset/metadata/text_1.0.0.yaml"
  region              = "us-central1"
}
# [END aiplatform_create_dataset_text_sample]

# [START aiplatform_create_dataset_video_sample]
resource "google_vertex_ai_dataset" "video_dataset" {
  display_name        = "video-dataset"
  metadata_schema_uri = "gs://google-cloud-aiplatform/schema/dataset/metadata/video_1.0.0.yaml"
  region              = "us-central1"
}
# [END aiplatform_create_dataset_video_sample]
