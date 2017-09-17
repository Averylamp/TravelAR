//
//  ViewController.swift
//  TrvlAR
//
//  Created by Avery Lamp on 9/16/17.
//  Copyright © 2017 Avery Lamp. All rights reserved.
//


import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!

    
    var planeCount = 0
    var currentPlane:SCNNode?
	var debuggingLabel = UILabel()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = false
        
        let tap = UITapGestureRecognizer()
		tap.numberOfTouchesRequired = 1
        tap.addTarget(self, action: #selector(didTap))
        sceneView.addGestureRecognizer(tap)
		
		//Three Finger Tap for Reset
		let threeFingerTap = UITapGestureRecognizer()
		threeFingerTap.numberOfTouchesRequired = 3
		threeFingerTap.addTarget(self, action: #selector(didThreeFingerTap))
		sceneView.addGestureRecognizer(threeFingerTap)
		
		//Debugging Label
		debuggingLabel.frame = CGRect(x: 0, y: self.view.frame.height-44, width: 400, height: 44)
		debuggingLabel.backgroundColor = .black;
		debuggingLabel.textColor = .white;
		view.addSubview(debuggingLabel)
    }
    
    // this func from Apple ARKit placing objects demo
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        if sceneView.scene.lightingEnvironment.contents == nil {
            if let environmentMap = UIImage(named: "Media.scnassets/environment_blur.exr") {
                sceneView.scene.lightingEnvironment.contents = environmentMap
            }
        }
        sceneView.scene.lightingEnvironment.intensity = intensity
    }
	
	func getConfiguration() -> ARWorldTrackingConfiguration {
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .horizontal
		configuration.isLightEstimationEnabled = true
		return configuration
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(getConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func anyPlaneFrom(location:CGPoint) -> (SCNNode, SCNVector3)? {
        let results = sceneView.hitTest(location,
                                        types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        print("anyPlaneFrom results \(results)")
        guard results.count > 0,
            let anchor = results[0].anchor,
            let node = sceneView.node(for: anchor) else { return nil }
        
        return (node, SCNVector3.positionFromTransform(results[0].worldTransform))
    }
    
    @objc func didTap(_ sender:UITapGestureRecognizer) {

		debuggingLabel.text = "Tap, tapped."
        let location = sender.location(in: sceneView)
        
        print("didTap \(location)")
        
        guard currentPlane == nil,
            let newPlaneData = anyPlaneFrom(location: location) else { return }
        
        
        print("adding wall???")
        currentPlane = newPlaneData.0
		
		
        let wallNode = SCNNode()
		let positionAddition = SCNVector3.init(newPlaneData.1.x+1.5, newPlaneData.1.y, newPlaneData.1.z)
		wallNode.position = positionAddition
        
        let sideLength = Nodes.WALL_LENGTH * 3
        let halfSideLength = sideLength * 0.5
        
        let endWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                       maskXUpperSide: true)
        endWallSegmentNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
        endWallSegmentNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT * 0.5), Float(Nodes.WALL_LENGTH) * -1.5)
        wallNode.addChildNode(endWallSegmentNode)
        
        let sideAWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                         maskXUpperSide: true)
        sideAWallSegmentNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
        sideAWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * -1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
        wallNode.addChildNode(sideAWallSegmentNode)
        
        let sideBWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                         maskXUpperSide: true)
        sideBWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * 1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
        wallNode.addChildNode(sideBWallSegmentNode)
        
        let doorSideLength = (sideLength - Nodes.DOOR_WIDTH) * 0.5
        
        let leftDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
                                                     maskXUpperSide: true)
        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        leftDoorSideNode.position = SCNVector3(Float(-halfSideLength + 0.5 * doorSideLength),
                                               Float(Nodes.WALL_HEIGHT) * Float(0.5),
                                               Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(leftDoorSideNode)
        
        let rightDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
                                                      maskXUpperSide: true)
        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        rightDoorSideNode.position = SCNVector3(Float(halfSideLength - 0.5 * doorSideLength),
                                                Float(Nodes.WALL_HEIGHT) * Float(0.5),
                                                Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(rightDoorSideNode)
        
        let aboveDoorNode = Nodes.wallSegmentNode(length: Nodes.DOOR_WIDTH,
                                                  height: Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT)
        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
        aboveDoorNode.position = SCNVector3(0,
                                            Float(Nodes.WALL_HEIGHT) - Float(Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT) * 0.5,
                                            Float(Nodes.WALL_LENGTH) * 1.5)
        wallNode.addChildNode(aboveDoorNode)
        
        let floorNode = Nodes.plane(pieces: 3,
                                    maskYUpperSide: false)
        floorNode.position = SCNVector3(0, 0, 0)
        wallNode.addChildNode(floorNode)
        
        let roofNode = Nodes.plane(pieces: 3,
                                   maskYUpperSide: true)
        roofNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT), 0)
        wallNode.addChildNode(roofNode)
        
        sceneView.scene.rootNode.addChildNode(wallNode)
        
        
        // we would like shadows from inside the portal room to shine onto the floor of the camera image(!)
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = UIColor.white
        floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        let floorShadowNode = SCNNode(geometry:floor)
        floorShadowNode.position = newPlaneData.1
        sceneView.scene.rootNode.addChildNode(floorShadowNode)
        
        
        let light = SCNLight()
        // [SceneKit] Error: shadows are only supported by spot lights and directional lights
        light.type = .ambient
        light.spotInnerAngle = 70
        light.spotOuterAngle = 120
        light.zNear = 0.00001
        light.zFar = 5
        light.castsShadow = true
        light.shadowRadius = 200
        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        light.shadowMode = .deferred
        let constraint = SCNLookAtConstraint(target: floorShadowNode)
        constraint.isGimbalLockEnabled = true
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(newPlaneData.1.x,
                                        newPlaneData.1.y + Float(Nodes.DOOR_HEIGHT),
                                        newPlaneData.1.z - Float(Nodes.WALL_LENGTH))
        lightNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(lightNode)
        
    }
    
    /// MARK: - ARSCNViewDelegate
    
    // this func from Apple ARKit placing objects demo
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // from apples app
        DispatchQueue.main.async {
            // If light estimation is enabled, update the intensity of the model's lights and the environment map
            if let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate {
                
                // Apple divived the ambientIntensity by 40, I find that, atleast with the materials used
                // here that it's a big too bright, so I increased to to 50..
                self.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 50)
            } else {
                self.enableEnvironmentMapWithIntensity(25)
            }
        }
    }
    
    // did at plane(?)
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        planeCount += 1
    }
    
    // did update plane?
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    // did remove plane?
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if node == currentPlane {
            //TODO: cleanup
        }
        
        if planeCount > 0 {
            planeCount -= 1
        }
    }
	
    @objc func didThreeFingerTap(_ sender:UITapGestureRecognizer) {
		debuggingLabel.text = "World Reset"
		sceneView.session.run(getConfiguration(), options: [.resetTracking, .removeExistingAnchors])
	}
}



