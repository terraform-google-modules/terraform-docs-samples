/**
 * Copyright 2023 Google LLC
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

# [START compute_reservation_create_specific_projects_reservation_instance_template]

resource "google_compute_reservation" "default" {
  name = "gce-reservation-specific-projects"
  zone = "us-central1-a"

  share_settings {
    share_type = "SPECIFIC_PROJECTS"

    project_map {
      {
        id = "project-1"
      }
      {
        id = "project-2"
      }
    }
  }

  /**
   * To use the source_instance_template field, you must omit the
   * instance_properties block. Attempting to use the instance_properties
   * block together with the source_instance_template field causes errors.
   */
  specific_reservation {
    count                    = 1
    source_instance_template = "example-instance-template"
  }

  /**
   * To let VMs with affinity for any reservation consume this reservation, omit
   * the specific_reservation_required field (default) or set it to false.
   */
  specific_reservation_required = false
}

# [END compute_reservation_create_specific_projects_reservation_instance_template]
