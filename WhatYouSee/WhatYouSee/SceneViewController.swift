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
import Vision

class SceneViewController: UIViewController {

    var visionRequests = [VNRequest]()
    let visionQueue = DispatchQueue(label: "com.melody5417.WhatYouSee")
    var latestPrediction: String = "" {
        didSet {
            print(latestPrediction)
        }
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
        setupVision()
        setupEvents()

        loopVisionUpdate()
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

    // MARK: Setup

    func setupScene() {
        sceneView.frame = self.view.bounds
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        view.addSubview(sceneView)

        let scene = SCNScene()
        sceneView.scene = scene
    }

    func setupEvents() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    func setupVision() {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("CoreMl model setup failed")
        }

        let classifyRst = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            guard error == nil else { return }
            guard let results = request.results else { return }

            let classifications = (results[0] as? VNClassificationObservation)!.identifier
            self?.latestPrediction = classifications
        }
        classifyRst.imageCropAndScaleOption = .centerCrop
        visionRequests = [classifyRst]
    }

    func loopVisionUpdate() {
        visionQueue.async {
            self.updateCoreML()
            self.loopVisionUpdate()
        }
    }

    // MARK: -
    func updateCoreML() {
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)

        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }



    // MARK: Statusbar
    override var prefersStatusBarHidden : Bool {
        return true
    }

    // MARK: Interaction

    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let tapPoint = gestureRecognizer.location(in: self.sceneView)
        let results = sceneView.hitTest(tapPoint, types: [.featurePoint])

        if let closestResult = results.first {
            // Get Coordinates of HitTest
            let transform : matrix_float4x4 = closestResult.worldTransform
            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

            let dimension: CGFloat = 1
            let textGeo = SCNText(string: self.latestPrediction, extrusionDepth: dimension)
            textGeo.font = UIFont.boldSystemFont(ofSize: 1)
            textGeo.alignmentMode = kCAAlignmentCenter

            let material = SCNMaterial()
            textGeo.materials = [material]
            textGeo.firstMaterial?.diffuse.contents = UIColor.orange
            textGeo.firstMaterial?.specular.contents = UIColor.white
            textGeo.firstMaterial?.isDoubleSided = true
            textGeo.chamferRadius = dimension
            let node = SCNNode(geometry: textGeo)

            let boundingBox = node.boundingBox
            node.pivot = SCNMatrix4MakeTranslation((boundingBox.max.x - boundingBox.min
                .x)/2.0, (boundingBox.max.y - boundingBox.min.y)/2.0, boundingBox.min.z)

            node.position = worldCoord
            node.scale = SCNVector3(0.01, 0.01, 0.01)
            if let eulerAngles = self.sceneView.session.currentFrame?.camera.eulerAngles {
                node.eulerAngles = SCNVector3(eulerAngles.x, eulerAngles.y, eulerAngles.z + .pi / 2)
            }

            print("position: \(node.position)")

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
