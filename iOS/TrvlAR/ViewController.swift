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
    
    var debuggingLabel = UILabel()
	var portals = [Portal]()
	
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
		
		//Text Field
		let textField = UITextField()
		textField.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
		textField.center = view.center
		textField.textAlignment = .center
		textField.placeholder = "Enter Location"
		textField.delegate = self
		textField.returnKeyType = .done
		textField.font = UIFont.systemFont(ofSize: 30)
		sceneView.addSubview(textField)
		
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
        sceneView.session.run(getConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @objc func didTap(_ sender:UITapGestureRecognizer) {
        
        debuggingLabel.text = "Tap, tapped."
        let location = sender.location(in: sceneView)
        
        print("didTap \(location)")
        
        let hitTestResults = sceneView.hitTest(location, types: [.featurePoint, .existingPlaneUsingExtent])
        
        if let closestResult = hitTestResults.first {
            self.debuggingLabel.text = "Added Portal"
            
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            //sceneView.session.add(anchor: ARAnchor(transform: transform))
			
			//sceneView.session.currentFrame?.camera.transform.columns.3
			
            let worldCoord = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
			
			let newPortal = Portal()
			
            print("adding wall???")
            
            newPortal.fullWalls.forEach{
                $0.removeFromParentNode()
            }
            newPortal.doorWalls.forEach{
                $0.removeFromParentNode()
            }
            newPortal.fullWalls = [SCNNode]()
            newPortal.doorWalls = [SCNNode]()
            
            let wallNode = SCNNode()
            wallNode.position = worldCoord
            //wallNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI/2.0))
            
            let sideLength = Nodes.WALL_LENGTH * 3
            let halfSideLength = sideLength * 0.5
            
            let endWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                           maskXUpperSide: true)
            endWallSegmentNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
            endWallSegmentNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT * 0.5), Float(Nodes.WALL_LENGTH) * -1.5)
            
            wallNode.addChildNode(endWallSegmentNode)
            newPortal.fullWalls.append(endWallSegmentNode)
            
            let sideAWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                             maskXUpperSide: true)
            sideAWallSegmentNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
            sideAWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * -1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
            wallNode.addChildNode(sideAWallSegmentNode)
            newPortal.fullWalls.append(sideAWallSegmentNode)
            
            let sideBWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
                                                             maskXUpperSide: true)
            sideBWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * 1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
            wallNode.addChildNode(sideBWallSegmentNode)
            newPortal.fullWalls.append(sideBWallSegmentNode)
            
            let doorSideLength = (sideLength - Nodes.DOOR_WIDTH) * 0.5
            
            let leftDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
                                                         maskXUpperSide: true)
            leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
            leftDoorSideNode.position = SCNVector3(Float(-halfSideLength + 0.5 * doorSideLength),
                                                   Float(Nodes.WALL_HEIGHT) * Float(0.5),
                                                   Float(Nodes.WALL_LENGTH) * 1.5)
            wallNode.addChildNode(leftDoorSideNode)
            newPortal.doorWalls.append(leftDoorSideNode)
            
            let rightDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
                                                          maskXUpperSide: true)
            rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
            rightDoorSideNode.position = SCNVector3(Float(halfSideLength - 0.5 * doorSideLength),
                                                    Float(Nodes.WALL_HEIGHT) * Float(0.5),
                                                    Float(Nodes.WALL_LENGTH) * 1.5)
            wallNode.addChildNode(rightDoorSideNode)
            newPortal.doorWalls.append(rightDoorSideNode)
            
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
//            let floor = SCNFloor()
//            floor.reflectivity = 0
//            floor.firstMaterial?.diffuse.contents = UIColor.white
//            floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
//            let floorShadowNode = SCNNode(geometry:floor)
//            floorShadowNode.position = worldCoord
//            sceneView.scene.rootNode.addChildNode(floorShadowNode)
			
            
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
//            let constraint = SCNLookAtConstraint(target: floorShadowNode)
//            constraint.isGimbalLockEnabled = true
            let lightNode = SCNNode()
            lightNode.light = light
            lightNode.position = SCNVector3(worldCoord.x,
                                            worldCoord.y + Float(Nodes.DOOR_HEIGHT),
                                            worldCoord.z - Float(Nodes.WALL_LENGTH))
            //lightNode.constraints = [constraint]
            sceneView.scene.rootNode.addChildNode(lightNode)
            AzureAPIManager.shared().getPictures(location: "Boston", completionHandler: { (results) in
                //if results != nil{
                    var images = [(UIImage, String)]()
                    results.forEach{
                        images.append($0!)
                    }
                    newPortal.addImagesToRoom(images: images)
                //}
            })
//            addImagesToRoom(images: [(#imageLiteral(resourceName: "cat0"), "Cat 1"),(#imageLiteral(resourceName: "cat1"), "Cat 2"),(#imageLiteral(resourceName: "cat2"), "Cat 3"),(#imageLiteral(resourceName: "cat3"), "Cat 4"),(#imageLiteral(resourceName: "cat4"), "Cat 5"),(#imageLiteral(resourceName: "cat5"), "Cat 6"),(#imageLiteral(resourceName: "cat6"), "Cat 7"),(#imageLiteral(resourceName: "cat7"), "Cat 8"),(#imageLiteral(resourceName: "cat8"), "Cat 9")])
        }
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
	
	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
		switch camera.trackingState {
		case .notAvailable:
			debuggingLabel.text = "Major Problem. Abort!"
		case .normal:
			debuggingLabel.text =  "All is good."
		case .limited(.excessiveMotion):
			debuggingLabel.text =  "Wow there buddy, slow down a bit."
		case .limited(.insufficientFeatures):
			debuggingLabel.text =  "Low detail; tracking will be limited."
		case .limited(.initializing):
			debuggingLabel.text =  "Warming Up..."
		}
	}
    
    
    // did update plane?
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }

    @objc func didThreeFingerTap(_ sender:UITapGestureRecognizer) {
		print("world reset")
        debuggingLabel.text = "World Reset"
		sceneView.session.pause()
		sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
			node.removeFromParentNode()}
        sceneView.session.run(getConfiguration(), options: [.resetTracking, .removeExistingAnchors])
    }
}


extension ViewController:UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

class Portal {
	var fullWalls = [SCNNode]()
	var doorWalls = [SCNNode]()
	
	var imageNodes = [SCNNode]()
	
	func addImagesToRoom(images: [(UIImage,  String)]){
		imageNodes.forEach {
			$0.removeFromParentNode()
		}
		let frameColor = UIColor.white
		for i in 0..<images.count{
			let image = images[i].0
			let caption = images[i].1
			let imageNode = SCNNode()
			if i == 0, let wallNode = fullWalls[0].childNode(withName: "WallSegment", recursively: false), let wallGeometry = wallNode.geometry as? SCNBox {
				let imageHtoWRatio = image.size.height / image.size.width
				let boxHtoWRatio:CGFloat = (wallGeometry.height / wallGeometry.length)
				var imageWidth:CGFloat = 0.0
				var imageHeight:CGFloat = 0.0
				if boxHtoWRatio > imageHtoWRatio{
					imageWidth = wallGeometry.length
					imageHeight = imageWidth * imageHtoWRatio
				}else{
					imageHeight = wallGeometry.height
					imageWidth = imageHeight / imageHtoWRatio
					
				}
				print("Image, Height: \(imageHeight), Width: \(imageWidth)")
				
				let imageNodeGeometry = SCNBox(width: Nodes.WALL_WIDTH, height: imageHeight, length: imageWidth, chamferRadius: 0.1)
				
				let frameMaterial = SCNMaterial()
				frameMaterial.diffuse.contents = frameColor
				let imageMaterial = SCNMaterial()
				imageMaterial.diffuse.contents = image
				imageNodeGeometry.materials = [frameMaterial, frameMaterial, frameMaterial, imageMaterial, frameMaterial, frameMaterial]
				imageNode.geometry = imageNodeGeometry
				var imagePosition = wallNode.position
				imagePosition.x = Float(-Nodes.WALL_WIDTH)
				imageNode.position = imagePosition
				wallNode.addChildNode(imageNode)
				imageNode.renderingOrder = 200
			}
			if 0 < i, i < 7, let wallNode = fullWalls[(i + 2) / 3].childNode(withName: "WallSegment", recursively: false), let wallGeometry = wallNode.geometry as? SCNBox{
				let imageHtoWRatio = image.size.height / image.size.width
				
				let imageWidth = (wallGeometry.length / 3) * 0.9 // Spacing factor
				let imageHeight = imageWidth * imageHtoWRatio
				print("Image, Height: \(imageHeight), Width: \(imageWidth)")
				let imageNodeGeometry = SCNBox(width: Nodes.WALL_WIDTH, height: imageHeight, length: imageWidth, chamferRadius: 0.1)
				
				let frameMaterial = SCNMaterial()
				frameMaterial.diffuse.contents = frameColor
				let imageMaterial = SCNMaterial()
				imageMaterial.diffuse.contents = image
				imageNodeGeometry.materials = [frameMaterial, frameMaterial, frameMaterial, imageMaterial, frameMaterial, frameMaterial]
				imageNode.geometry = imageNodeGeometry
				var imagePosition = wallNode.position
				imagePosition.x = Float(-Nodes.WALL_WIDTH)
				let offset = (-wallGeometry.length / 3)
				imagePosition.z = Float(offset) * Float(((i + 2) % 3) - 1)
				imageNode.position = imagePosition
				wallNode.addChildNode(imageNode)
				imageNode.renderingOrder = 200
			}
			if  i - 7 >= 0, i - 7 < 9, i - 7 < doorWalls.count, let wallNode = doorWalls[i - 7].childNode(withName: "WallSegment", recursively: false), let wallGeometry = wallNode.geometry as? SCNBox{
				let imageHtoWRatio = image.size.height / image.size.width
				
				let imageWidth = wallGeometry.length * 0.8 // Spacing factor
				let imageHeight = imageWidth * imageHtoWRatio
				print("Image, Height: \(imageHeight), Width: \(imageWidth)")
				let imageNodeGeometry = SCNBox(width: Nodes.WALL_WIDTH, height: imageHeight, length: imageWidth, chamferRadius: 0.1)
				
				let frameMaterial = SCNMaterial()
				frameMaterial.diffuse.contents = frameColor
				let imageMaterial = SCNMaterial()
				imageMaterial.diffuse.contents = image
				imageNodeGeometry.materials = [frameMaterial, frameMaterial, frameMaterial, imageMaterial, frameMaterial, frameMaterial]
				imageNode.geometry = imageNodeGeometry
				var imagePosition = wallNode.position
				imagePosition.x = Float(-Nodes.WALL_WIDTH)
				imageNode.position = imagePosition
				wallNode.addChildNode(imageNode)
				imageNode.renderingOrder = 200
			}
			if i != 0{
				let textGeometry = SCNText(string: caption, extrusionDepth: CGFloat(0.01))
				var font = UIFont(name: "Avenir-Roman", size: 0.06)
				font = font?.withTraits(traits: .traitBold)
				textGeometry.font = font
				textGeometry.alignmentMode = kCAAlignmentCenter
				textGeometry.firstMaterial?.diffuse.contents = UIColor.black
				textGeometry.firstMaterial?.specular.contents = UIColor.white
				textGeometry.firstMaterial?.isDoubleSided = true
				// bubble.flatness // setting this too low can cause crashes.
				textGeometry.chamferRadius = CGFloat(0.01)
				
				// Text Node
				let (minBound, maxBound) = textGeometry.boundingBox
				let textNode = SCNNode(geometry: textGeometry)
				textNode.pivot = SCNMatrix4MakeTranslation((maxBound.x - minBound.x)/2,(maxBound.y - minBound.y)/2,0)
				var textPosition = SCNVector3Make(0, 0, 0)
				if let _ = imageNode.geometry as? SCNBox{
					textPosition.y -= 0.3
				}
				textNode.position = textPosition
				textNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
				textNode.renderingOrder = 200
				//            textNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
				imageNode.addChildNode(textNode)
			}
		}
	}
}

