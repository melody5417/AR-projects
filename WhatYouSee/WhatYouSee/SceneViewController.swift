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
        sceneView.autoenablesDefaultLighting = true
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

            let dimension: CGFloat = 1
            let textGeo = SCNText(string: "hello", extrusionDepth: dimension)
            textGeo.font = UIFont.boldSystemFont(ofSize: 10)
            textGeo.alignmentMode = kCAAlignmentCenter

            let material = SCNMaterial()
            textGeo.materials = [material]
            textGeo.firstMaterial?.diffuse.contents = UIColor.orange
            textGeo.firstMaterial?.specular.contents = UIColor.white
            textGeo.firstMaterial?.isDoubleSided = true
            textGeo.chamferRadius = dimension
            let node = SCNNode(geometry: textGeo)

            // 最后把 transform 传给 node 的 position
            node.position = worldCoord
            node.scale = SCNVector3(0.01, 0.01, 0.01)
            if let eulerAngles = self.sceneView.session.currentFrame?.camera.eulerAngles {
                node.eulerAngles = SCNVector3(eulerAngles.x, eulerAngles.y, eulerAngles.z + .pi / 2)
            }

            print("position: \(node.position)")

            // 最后把精灵加入到 sceneView 的根节点
            sceneView.scene.rootNode.addChildNode(node)
        }
    }


    // MARK: Property

    private let sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.showsStatistics = true
        return view
    }()

}

extension SceneViewController: ARSCNViewDelegate {


}
