//
//  ViewController.swift
//  AR Ruler
//
//  Created by user on 01.05.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: sceneView) else {return}
        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) else {return}
        let results = sceneView.session.raycast(query)
        
        if let hitREsult = results.first {
            addDot(atLocation: hitREsult)
        }
    }
    
    func addDot(atLocation location: ARRaycastResult) {
        if dotNodes.count >= 2 {
            for dotNode in dotNodes {
                dotNode.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            textNode.removeFromParentNode()
        }
        let dotGeomettry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeomettry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeomettry)
        dotNode.position = SCNVector3(
            x: location.worldTransform.columns.3.x,
            y: location.worldTransform.columns.3.y,
            z: location.worldTransform.columns.3.z
        )
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let start = dotNodes[0].position
        let end = dotNodes[1].position
        
        let distance = sqrt(pow(end.x - start.x, 2) +
                            pow(end.y - start.y, 2) +
                            pow(end.z - start.z, 2)
        )
        
        updateText(result: "\(abs(distance))", atPosition: end)
        
    }
    
    func updateText(result text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: position.x, y: position.y, z: position.z)
        textNode.scale = SCNVector3(x: 0.005, y: 0.005, z: 0.005)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
