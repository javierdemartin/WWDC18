// WWDC18 Scholarship Submission by Javier de Martín

// Planet assets used under Attribution 4.0 (https://www.solarsystemscope.com/textures)
// Following this tuto: https://www.appcoda.com/arkit-horizontal-plane/

import ARKit
import UIKit
import SceneKit
import PlaygroundSupport

let usingMac  = false
let isInDebug = true
var alreadyAdded = false
var userReadInstructions = false

// ARKit
//---------------------------------------------------------------

// Main ARKIT ViewController
class ViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform
        let x = translation.columns.3.x
        let y = translation.columns.3.y
        let z = translation.columns.3.z
        
        solarSystem = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        solarSystem.getRootNode().position = SCNVector3(x,y,z)
        
        self.sceneView.scene.rootNode.addChildNode(solarSystem.getRootNode())
        
        alreadyAdded = true
    }
    
    var solarSystem : PlanetaryView!

    // Adds a UITapGestureRecognizer to add the Solar System projection when the user taps on a detected surface
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print(self.view.frame)
        
        sceneView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        
        presentStuff()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.view.frame)
        
        
//        sceneView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        
        sceneView.delegate = self as ARSCNViewDelegate
        
        if isInDebug {
            sceneView.showsStatistics = true
        }
        
        
        sceneView.scene.rootNode // Create a new scene
        sceneView.autoenablesDefaultLighting = true // Add ligthing
        
        
        
        print(self.view.frame)
        
        addTapGestureToSceneView()
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        
        if sender.tag == 11 {
            print("button")
            
            if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
                print("Removed")
                userReadInstructions = true
            }
        }
    }
    
    func presentStuff() {
        
        if !userReadInstructions {
            
            print(self.view.frame)
            
            let presentationView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height))
            presentationView.tag = 100
            
            presentationView.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 0.2)
            
            let title = UILabel(frame: CGRect(x: 10, y: self.view.frame.height / 5, width: self.view.frame.width - 10, height: 50))
            title.text = "PlanetARium"
            title.textColor = UIColor.white
            title.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
            title.textAlignment = .left
            
            let subtitle = UILabel(frame: CGRect(x: 10, y: (2 * self.view.frame.height) / 5, width: self.view.frame.width - 10, height: 100))
            subtitle.text = "Once PlanetARium detects a flat surface tap the surface to discover the Solar System and learn how the planets  move"
            subtitle.numberOfLines = 10
            subtitle.textColor = UIColor.white
            subtitle.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            subtitle.textAlignment = .left
            
            
            
            self.view.addSubview(presentationView)
            
            let acceptButton = UIButton(frame: CGRect(x: self.view.frame.width / 2, y: self.view.frame.maxY - 100.0, width: 80.0, height: 80.0))
            acceptButton.tag = 11
            acceptButton.setTitle("👍🏼", for: .normal)
            acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .regular)
            acceptButton.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 0.5)
            acceptButton.layer.cornerRadius = acceptButton.frame.height/2
            acceptButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            
            presentationView.addSubview(title)
            presentationView.addSubview(subtitle)
            presentationView.addSubview(acceptButton)
        }
    }
    
     override func loadView() {
        
        sceneView = ARSCNView()
        sceneView.delegate = self
        
        
        
        if isInDebug {
            sceneView.debugOptions = [.showBoundingBoxes, .showCameras, .showConstraints]
        }

        let config            = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal

        sceneView.session.delegate = self // Now we'll get messages when planes were detected...

        self.view = sceneView
        sceneView.session.run(config, options: [.resetTracking,.removeExistingAnchors])
     }
    
    // This protocol method gets called every time the scene view’s session has a new ARAnchor added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Added node")
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor(red: 10/255, green: 200/255, blue: 255/255, alpha: 0.2)
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
    }
    
    // This method gets called every time a SceneKit node’s properties have been updated to match its corresponding anchor.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

// SceneKit
//---------------------------------------------------------------

class EarthScene: SCNScene  {
    
    let planets : [String : Double] = ["mercury" : 2, "venus" : 5, "earth" : 7, "mars" : 9, "jupiter" : 11, "saturn" : 13, "uranus" : 15, "neptune" : 17]
    
    // Radios de los planetas en kiló
    let planetsRadius : [String : Double] = ["mercury" : 3, "venus" : 5, "earth" : 7, "mars" : 9, "jupiter" : 11, "saturn" : 13, "uranus" : 15, "neptune" : 17]
    
    // Speed rotation of a planet on days
    var planetsRotations : [String : CGFloat] = ["mercury" : 1/87.969, "venus" : 1/224.7, "earth" : 1/365.25, "mars" : 1/320, "jupiter" : 1/(11.8618 * 365), "saturn" : 1/10759, "uranus" : 1/30688.5, "neptune" : 1/60182]
    
    // Sun
    let sunNode: SCNNode              = SCNNode()
    let sunNodeRotationSpeed: CGFloat = CGFloat(0.2) //CGFloat(Double.pi/6)
    var sunNodeRotation: CGFloat      = 0
    let sunRadius : Float             = 2 // Real en UA
    
    // Observer
    let observerNode = SCNNode()
    
    override init()  {
        
        super.init()
        
        addStar(name: "sun")
        addPlanet(name: "mercury", speed: planetsRotations["mercury"]! * 20, planetRadius: 0.2)
//        addPlanet(name: "venus", speed: planetsRotations["venus"]! * 20, planetRadius: 0.5)
//        addPlanet(name: "earth", speed: planetsRotations["earth"]! * 20, planetRadius: 1)
//        addPlanet(name: "mars", speed: planetsRotations["mars"]! * 20, planetRadius: 0.75)
//        addPlanet(name: "jupiter", speed: planetsRotations["jupiter"]! * 20, planetRadius: 0.5)
//        addPlanet(name: "saturn", speed: planetsRotations["saturn"]! * 20, planetRadius: 1.5)
//        addPlanet(name: "uranus", speed: planetsRotations["uranus"]! * 20, planetRadius: 0.7)
//        addPlanet(name: "neptune", speed: planetsRotations["neptune"]! * 20, planetRadius: 0.2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpObserver() {
        
        //Set up initial camera's position
        observerNode.camera = SCNCamera()
        observerNode.position = SCNVector3(x:0, y: 10, z: 0)
        
        rootNode.addChildNode(observerNode)
    }
    
    //function to revole any node to the left
    func revolve(node: SCNNode ,value: CGFloat, increase: CGFloat) -> CGFloat {
        
        var rotation = value
        
        if value < CGFloat(-Double.pi*2) {
            
            rotation = value + CGFloat(Double.pi*2)
            node.rotation = SCNVector4(x: 0.0, y: 10.0, z: 0.0, w: Float(rotation))
        }
        
        return rotation - increase
    }

    func getRootNode() -> SCNNode {
        
        rootNode.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        return rootNode
    }
    
    func addStar(name: String) {
        
        let helperNode            = SCNNode()
    
        let observerMaterial = SCNMaterial()
        observerMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
        
        let observerGeometry = SCNSphere(radius: 1.5)
        observerGeometry.firstMaterial = observerMaterial
        
        let observerLight = SCNLight()
        observerLight.type = SCNLight.LightType.ambient
        observerLight.color = UIColor(white: 0.15, alpha: 1.0)
        
        sunNode.position = SCNVector3(0, 0, 0)
        sunNode.geometry = observerGeometry
        sunNode.light = observerLight
        
        sunNodeRotation   = revolve(node: sunNode, value: sunNodeRotation, increase: 1)
        sunNode.rotation   = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(sunNodeRotation))
        
        rootNode.addChildNode(sunNode)
        sunNode.addChildNode(helperNode)
        
        myAnimation(nextNode: sunNode, rotation: sunNodeRotation, speed: 1)
    }
    
    func addPlanet(name: String, speed: CGFloat, planetRadius : CGFloat) {
        
        let nextNode = SCNNode()
        let helperAuxNode = SCNNode()
        
        nextNode.name = name
        
        let earthMaterial              = SCNMaterial()
        earthMaterial.ambient.contents = UIColor(white: 0.7, alpha: 1.0)
        earthMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
        
        earthMaterial.specular.intensity = 1
        earthMaterial.shininess = 0.05
        earthMaterial.multiply.contents = UIColor(white: 0.7, alpha: 1.0)
        
        //Earth is a sphere with radius 5
        let earthGeometry = SCNSphere(radius: CGFloat(planetRadius))
        earthGeometry.firstMaterial = earthMaterial
        
        nextNode.geometry = earthGeometry
        nextNode.position = SCNVector3(planets[name]!, 0.0, 0.0)
        
        planetsRotations[name]!   = revolve(node: nextNode, value: planetsRotations[name]!, increase: 200)
        nextNode.rotation  = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(planetsRotations[name]!))
        
        rootNode.addChildNode(helperAuxNode)
        helperAuxNode.addChildNode(nextNode)
        
            // Traslacion
        myAnimation(nextNode: helperAuxNode, rotation: planetsRotations[name]!, speed: speed)
        myAnimation(nextNode: nextNode, rotation: planetsRotations[name]!, speed: speed * 100)
    }
    
    func myAnimation(nextNode: SCNNode, rotation: CGFloat, speed : CGFloat) {
        
        var mutableRotation = rotation
        
        mutableRotation   = revolve(node: nextNode, value: mutableRotation, increase: speed)
        
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = (CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear))
        
        SCNTransaction.animationDuration = 1
        SCNTransaction.completionBlock = {
            self.myAnimation(nextNode: nextNode, rotation: mutableRotation, speed: speed)
        }
        
        nextNode.rotation   = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(mutableRotation))
        
        SCNTransaction.commit()
    }
}

//SCNView for presenting the Scene
class PlanetaryView: SCNView {
    
    let earthScene: EarthScene = EarthScene()
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: nil)
        //Allow user to adjust viewing angle
        allowsCameraControl = true
        backgroundColor = UIColor.black
        autoenablesDefaultLighting = true
        scene = earthScene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getRootNode() -> SCNNode {
        return earthScene.getRootNode()
    }
}

if usingMac {
    PlaygroundPage.current.liveView = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: 800.0, height: 800.0))
} else {
    PlaygroundPage.current.liveView = ViewController()
}

PlaygroundPage.current.needsIndefiniteExecution = true
