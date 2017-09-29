package org.bigbluebutton.modules.present.model {
    import mx.collections.ArrayCollection;

    import org.as3commons.logging.api.ILogger;
    import org.as3commons.logging.api.getClassLogger;
    import org.bigbluebutton.modules.present.services.messages.PageChangeVO;
    import org.bigbluebutton.modules.present.model.PresentationModel;
    import org.bigbluebutton.modules.present.events.RequestNewPresentationPodEvent;
    import com.asfusion.mate.events.Dispatcher;
    import org.bigbluebutton.core.UsersUtil;


    import org.bigbluebutton.modules.present.events.NewPresentationPodCreated;
    import org.bigbluebutton.modules.present.events.PresentationPodRemoved;
    import org.bigbluebutton.modules.present.events.RequestPresentationInfoPodEvent;

    import org.bigbluebutton.main.api.JSLog;
    
    public class PresentationPodManager {
        private static const LOGGER:ILogger = getClassLogger(PresentationPodManager);
    
        private static var instance:PresentationPodManager = null;
    
        private var _presentationPods: ArrayCollection = new ArrayCollection();
        private var globalDispatcher:Dispatcher;


        /**
         * This class is a singleton. Please initialize it using the getInstance() method.
         *
         */
        public function PresentationPodManager(enforcer:SingletonEnforcer) {
            if (enforcer == null) {
                throw new Error("There can only be 1 PresentationPodManager instance");
            }
            globalDispatcher = new Dispatcher();

            initialize();
        }
    
        private function initialize():void {
            JSLog.warn("+++ PresentationPodManager:: initialize: ", {});
        }
    
        /**
         * Return the single instance of the PresentationPodManager class
         */
        public static function getInstance():PresentationPodManager {
            if (instance == null) {
                instance = new PresentationPodManager(new SingletonEnforcer());
                instance.requestDefaultPresentationPod();
            }

            return instance;
        }
        
        public function requestDefaultPresentationPod(): void {
            JSLog.warn("+++ PresentationPodManager::requestDefaultPresentationPod ", {});
            
            var event:RequestNewPresentationPodEvent = new RequestNewPresentationPodEvent(RequestNewPresentationPodEvent.REQUEST_NEW_PRES_POD);
            event.requesterId = UsersUtil.getMyUserID();
            globalDispatcher.dispatchEvent(event);
        }
        
        public function getPod(podId: String): PresentationModel {
//            return _presentationPods[podId];
            
            var resultingPod: PresentationModel = getFirstPod(); // TODO
            for (var i:int = 0; i < _presentationPods.length; i++) {
                var pod: PresentationModel = _presentationPods.getItemAt(i) as PresentationModel;
                JSLog.warn("+++ PresentationPodManager:: getPod for podId=" + podId + "     " + pod.getPodId(), {});

                if (pod.getPodId() == podId) {
                    JSLog.warn("+++ PresentationPodManager:: getPod SUCCESS for podId=" + podId , {});
                    return pod;
                }
            }
            JSLog.warn("+++ PresentationPodManager:: getPod FAIL for podId=" + podId , {});
            return resultingPod;
        }


        public function getFirstPod(): PresentationModel {
            JSLog.warn("+++ PresentationPodManager:: getFirstPod size=" + _presentationPods.length, {});
            return _presentationPods.getItemAt(0) as PresentationModel;
        }
        
        public function handleAddPresentationPod(podId: String, ownerId: String): void {
            for (var i:int = 0; i < _presentationPods.length; i++) {
                var pod: PresentationModel = _presentationPods.getItemAt(i) as PresentationModel;
                if (pod.getPodId() == podId) {
                    JSLog.warn("+++ (DUPLICATE FOUND) PresentationPodManager::handleAddPresentationPod " + podId, {});
                    return;
                }
            }

            var newPod: PresentationModel = new PresentationModel(podId, ownerId);
            _presentationPods.addItem(newPod);
            JSLog.warn("+++ after (SUCCESS) PresentationPodManager::handleAddPresentationPod " + podId + " size=" + _presentationPods.length, {});
        }
        
        public function handlePresentationPodRemoved(podId: String, ownerId: String): void {
            JSLog.warn("+++ PresentationPodManager::handlePresentationPodRemoved " + podId, {});

            for (var i:int = 0; i < _presentationPods.length; i++) {
                var pod: PresentationModel = _presentationPods.getItemAt(i) as PresentationModel;
                JSLog.warn("+++ PresentationPodManager:: remove for podId=" + podId + "    final size= " + _presentationPods.length, {});

                if (pod.getPodId() == podId) {
                    _presentationPods.removeItemAt(i);
                    JSLog.warn("+++ (SUCCESS) PresentationPodManager:: remove for podId=" + podId + "    final size= " + _presentationPods.length, {});
                    return;
                }
            }
            JSLog.warn("+++ (FAIL) PresentationPodManager:: remove for podId=" + podId + "    final size= " + _presentationPods.length, {});
            
        }
        
        public function requestAllPodsPresentationInfo(): void {
            JSLog.warn("+++ PresentationPodManager:: requestAllPodsPresentationInfo" + _presentationPods.length, {});
            for (var i:int = 0; i < _presentationPods.length; i++) {
                var pod: PresentationModel = _presentationPods.getItemAt(i) as PresentationModel;

                var event:RequestPresentationInfoPodEvent = new RequestPresentationInfoPodEvent(RequestPresentationInfoPodEvent.REQUEST_PRES_INFO);
                event.podId = pod.getPodId();
                globalDispatcher.dispatchEvent(event);
            }
        }
    
    }
}

class SingletonEnforcer{}
