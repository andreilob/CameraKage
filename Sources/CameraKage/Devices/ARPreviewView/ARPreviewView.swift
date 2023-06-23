//
//  ARPreviewView.swift
//  
//
//  Created by Lobont Andrei on 20.06.2023.
//

import ARKit
import SceneKit

class ARPreviewView: ARSCNView, ARPreviewer {
    private let options: ARCameraComponentParsedOptions
    private var faceGeometry = ARSCNFaceGeometry(device: MTLCreateSystemDefaultDevice()!)
    private var faceOverlayNode: SCNNode?
    lazy var renderer: SCNRenderer = {
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice()!, options: nil)
        renderer.scene = scene
        renderer.autoenablesDefaultLighting = options.autoenablesDefaultLighting
        renderer.isJitteringEnabled = options.isJitteringEnabled
        renderer.isTemporalAntialiasingEnabled = options.isTemporalAntialiasingEnabled
        return renderer
    }()
    
    var isSessionRunning: Bool { isPlaying }
    
    weak var sessionDelegate: ARSessionDelegate?
    
    init(options: ARCameraComponentParsedOptions) {
        self.options = options
        super.init(frame: .zero, options: nil)
        delegate = self
        autoenablesDefaultLighting = options.autoenablesDefaultLighting
        isJitteringEnabled = options.isJitteringEnabled
        isTemporalAntialiasingEnabled = options.isTemporalAntialiasingEnabled
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder not implemented.")
    }
    
    func startCameraSession() {
        resetCamera()
    }
    
    func stopCameraSession() {
        session.pause()
    }
    
    func loadARMask(name: String, fileType: String) {
        let path = "\(name).\(fileType)"
        guard let scene = SCNScene(named: path) else {
            sessionDelegate?.arSession(didFailWithError: .failedToLoadARMask(name: name,
                                                                             fileType: fileType))
            faceOverlayNode = nil
            resetCamera()
            return
        }
        faceOverlayNode = scene.rootNode
        faceOverlayNode?.childNodes[0].morpher?.unifiesNormals = true
        resetCamera()
    }
    
    func embedPreview(inView view: UIView) {
        view.addSubview(self)
        layoutToFill(inView: view)
    }
    
    func resetCamera() {
        guard ARFaceTrackingConfiguration.isSupported else {
            sessionDelegate?.arSession(didFailWithError: .arNotSupported)
            return
        }
        let configuration = ARFaceTrackingConfiguration()
        configuration.providesAudioData = true
        configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

// MARK: - ARSCNViewDelegate
extension ARPreviewView: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionDelegate?.arSession(didFailWithError: .arSessionFailed(message: error.localizedDescription))
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        sessionDelegate?.arSessionWasInterrupted()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        sessionDelegate?.arSessionInterruptionEnded()
    }
    
    func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
        sessionDelegate?.arSession(didOutputAudioBuffer: audioSampleBuffer)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        faceGeometry?.update(from: faceAnchor.geometry)
        faceGeometry?.firstMaterial?.colorBufferWriteMask = []
        let occlusionNode = SCNNode(geometry: faceGeometry)
        occlusionNode.renderingOrder = -1
        faceOverlayNode?.addChildNode(occlusionNode)
        return faceOverlayNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        faceAnchor.blendShapes.forEach { (key, value) in
            faceOverlayNode?.childNodes[0].morpher?.setWeight(CGFloat(value.floatValue), forTargetNamed: key.rawValue)
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        true
    }
}
