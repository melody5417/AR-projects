//
//  SceneViewController.swift
//  WhatYouSee
//
//  Created by yiqiwang(王一棋) on 2018/2/6.
//  Copyright © 2018年 melody5417. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class SceneViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.frame = self.view.bounds
        sceneView.automaticallyUpdatesLighting = true
        sceneView.delegate = self
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        view.addSubview(sceneView)

        let scene = SCNScene()
        sceneView.scene = scene

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        sceneView.session.pause()
    }

    // MARK: Statusbar
    override var prefersStatusBarHidden : Bool {
        return true
    }

    // MARK: Interaction

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {

        // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
        let tapPoint = gestureRecognizer.location(in: self.sceneView)
        let results = sceneView.hitTest(tapPoint, types: [.featurePoint])

        // If the intersection ray passes through any plane geometry they will be returned, with the planes
        // ordered by distance from the camera
        if let closestResult = results.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

            let dimension: CGFloat = 0.1
            let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
            let node = SCNNode(geometry: cube)

//             // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
//            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//            node.physicsBody?.mass = 2.0

            // 最后把 transform 传给 node 的 position
            node.position = worldCoord

            // 最后把精灵加入到 sceneView 的根节点
            sceneView.scene.rootNode.addChildNode(node)
        }


//        // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
//        let tapPoint = gestureRecognizer.location(in: self.sceneView)
//        let results = sceneView.hitTest(tapPoint, types: [.featurePoint])
//
//        // If the intersection ray passes through any plane geometry they will be returned, with the planes
//        // ordered by distance from the camera
//        if let closestResult = results.first {
//            let dimension: CGFloat = 0.1
//            let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
//            let node = SCNNode(geometry: cube)
//
//             // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
//            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
//            node.physicsBody?.mass = 2.0
//
//            // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
//            // using the physics engine
//            let insertionYOffset: Float = 0.5
//            node.position = SCNVector3Make(closestResult.worldTransform.columns.3.x,
//                                           closestResult.worldTransform.columns.3.y + insertionYOffset,
//                                           closestResult.worldTransform.columns.3.z)
//            sceneView.scene.rootNode.addChildNode(node)
//
//        }

        
//        guard let currentFrame = sceneView.session.currentFrame else {
//            return
//        }
//
//        // 创建一个 plane。并设置大小，这里的大小单位接近米，不能太大，否则最后会挡住我们的视线，看不出效果
//        let plane = SCNPlane(width: 0.6, height: 0.4)
//
//        // Meterial 就是我们的材料，也就是纹理，我们设置纹理的内容为一个 UIImage 对象
//        plane.firstMaterial?.diffuse.contents = UIImage(named: "images")
//        plane.firstMaterial?.lightingModel = .constant
//
//        // 利用创建好的 plane 来创建一个精灵（Node）
//        let planeNode = SCNNode(geometry: plane)
//
//        // 熟悉 SceneKit 的朋友应该都了解这里的操作，这里的重点是利用 currentFrame 的 camera 属性来获取 transform
//        // 这个 transform 的各种位置属性就是当前摄像机所处的位置信息，所以我们可以直接利用它
//        var translation = matrix_identity_float4x4
//        translation.columns.3.z = -20
//        let transform = matrix_multiply(currentFrame.camera.transform, translation)
//
//        // 最后把 transform 传给 node 的 simdTransform
//        planeNode.simdTransform = transform
//
//        // 最后把精灵加入到 sceneView 的根节点
//        sceneView.scene.rootNode.addChildNode(planeNode)


//        // HIT TEST : REAL WORLD
//        // Get Screen Centre
//        let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
//
//        let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
//
//        if let closestResult = arHitTestResults.first {
//            print("arHitTestResults: \(arHitTestResults)")
//
//            // Get Coordinates of HitTest
//            let transform : matrix_float4x4 = closestResult.worldTransform
//            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
//
//            // 创建一个 plane。并设置大小，这里的大小单位接近米，不能太大，否则最后会挡住我们的视线，看不出效果
//            let plane = SCNPlane(width: 0.6, height: 0.4)
//
//            // Meterial 就是我们的材料，也就是纹理，我们设置纹理的内容为一个 UIImage 对象
//            plane.firstMaterial?.diffuse.contents = UIImage(named: "images")
//            plane.firstMaterial?.lightingModel = .constant
//
//            // 利用创建好的 plane 来创建一个精灵（Node）
//            let planeNode = SCNNode(geometry: plane)
//
//            // 最后把 transform 传给 node 的 position
//            planeNode.position = worldCoord
//
//            // 最后把精灵加入到 sceneView 的根节点
//            sceneView.scene.rootNode.addChildNode(planeNode)
//        }
    }


    // MARK: Property

    private let sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.showsStatistics = true
        return view
    }()

}

extension SceneViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This visualization covers only detected planes.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // Create a SceneKit plane to visualize the node using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)

        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
    }

}
