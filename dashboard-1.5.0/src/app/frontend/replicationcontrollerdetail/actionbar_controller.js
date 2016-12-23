// Copyright 2015 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * @final
 */
export class ActionBarController {
  /**
   * @param {!backendApi.ReplicationControllerDetail} replicationControllerDetail
   * @param {!./replicationcontroller_service.ReplicationControllerService}
   * kdReplicationControllerService
   * @ngInject
   */
  constructor(replicationControllerDetail, kdReplicationControllerService) {
    /** @private {!./replicationcontroller_service.ReplicationControllerService} */
    this.kdReplicationControllerService_ = kdReplicationControllerService;

    /** @export {!backendApi.ReplicationControllerDetail} */
    this.details = replicationControllerDetail;
  }
  /**
   * Handles update of replicas count in replication controller dialog.
   * @export
   */
  handleUpdateReplicasDialog() {
    this.kdReplicationControllerService_.showUpdateReplicasDialog(
        this.details.objectMeta.namespace, this.details.objectMeta.name,
        this.details.podInfo.current, this.details.podInfo.desired);
  }
}
