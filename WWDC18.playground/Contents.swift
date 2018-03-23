// ARSCNView test

// TODO : Add tap gesture recognizers on each planet to display information

// Following this tuto: https://www.appcoda.com/arkit-horizontal-plane/

import ARKit
import UIKit
import SceneKit
import PlaygroundSupport

// ARKit
//---------------------------------------------------------------


// Main ARKIT ViewController
class MyARTest : UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the views delegate
        sceneView.delegate = self as ARSCNViewDelegate
        sceneView.showsStatistics = true
       
        sceneView.scene.rootNode // Create a new scene
        sceneView.autoenablesDefaultLighting = true // Add ligthing
        
        let solarSystem = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        
     //  add new node to root node
        self.sceneView.scene.rootNode.addChildNode(solarSystem.getRootNode())
    }
    
     override func loadView() {

        sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [.showBoundingBoxes, .showCameras, .showConstraints]

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal

        // Now we'll get messages when planes were detected...
        sceneView.session.delegate = self

        self.view = sceneView
        sceneView.session.run(config, options: [.resetTracking,.resetTracking])
     }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Added node")
    }
}

// SceneKit
//---------------------------------------------------------------

class EarthScene: SCNScene  {
    
    // Moon
    let moonNode : SCNNode             = SCNNode()
    let moonNodeRotationSpeed: CGFloat = 1 //CGFloat(Double.pi/8)
    var moonNodeRotation: CGFloat      = 0
    let moonRadius : Float             = 0.5 // 0.000011614
    
    // Earth
    let earthNode: SCNNode = SCNNode()
    var earthNodeRotation: CGFloat = 0
    let earthNodeRotationSpeed: CGFloat = 1 //CGFloat(0.1965) //CGFloat(Double.pi/40)
    let earthRadius : Float = 1 // 0.00004258756 Real
    
    // Sun
    let sunNode: SCNNode              = SCNNode()
    let sunNodeRotationSpeed: CGFloat = CGFloat(1.997) //CGFloat(Double.pi/6)
    var sunNodeRotation: CGFloat      = 0
    let sunRadius : Float             = 2 // Real en UA
    
    // Observer
    let observerNode: SCNNode = SCNNode()
    let helperNode            = SCNNode()
    let helperNodeSunEarth    = SCNNode()
    
    override init()  {
        
        super.init()
        
        setUpObserver()
        setUpSun()
        setUpEarth()
        setUpMoon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpObserver() {
        
        //Set up initial camera's position
        observerNode.camera = SCNCamera()
        observerNode.position = SCNVector3(x:0, y: 0, z: 10)
        
        rootNode.addChildNode(observerNode)
    }
    
    func setUpMoon() {
        
        let moonGeometry = SCNSphere(radius: CGFloat(earthRadius/2))
        
        let moonMaterial = SCNMaterial()
        
        moonMaterial.specular.intensity = 1.0
        moonMaterial.diffuse.contents = UIImage(named: "moon.jpg")
        moonMaterial.ambient.contents = UIColor(white: 0.7, alpha: 1.0)
        moonMaterial.shininess = 0.05
        
        moonGeometry.firstMaterial = moonMaterial
        
        moonNode.geometry = moonGeometry
        moonNode.position = SCNVector3(2.5,0, 0)
        
        helperNode.addChildNode(moonNode)
    }
    
    func setUpSun() {
        
        let observerMaterial = SCNMaterial()
        observerMaterial.specular.intensity = 1.0
        observerMaterial.diffuse.contents = UIImage(named: "sun.jpg")
        
        let observerGeometry = SCNSphere(radius: 1)
        observerGeometry.firstMaterial = observerMaterial
        
        
        let observerLight = SCNLight()
        observerLight.type = SCNLight.LightType.ambient
        observerLight.color = UIColor(white: 0.15, alpha: 1.0)
        
        
        sunNode.geometry = observerGeometry
        sunNode.light = observerLight
        
        rootNode.addChildNode(sunNode)
        sunNode.addChildNode(helperNodeSunEarth)
    }
    
    func setUpEarth() {
        
        let earthMaterial              = SCNMaterial()
        earthMaterial.ambient.contents = UIColor(white: 0.7, alpha: 1.0)
        earthMaterial.diffuse.contents = UIImage(named: "earth.jpg")
        
        earthMaterial.specular.intensity = 1
        earthMaterial.shininess = 0.05
        earthMaterial.multiply.contents = UIColor(white: 0.7, alpha: 1.0)
        
        //Earth is a sphere with radius 5
        let earthGeometry = SCNSphere(radius: CGFloat(earthRadius))
        earthGeometry.firstMaterial = earthMaterial
        
        earthNode.geometry = earthGeometry
        earthNode.position = SCNVector3(6.0, 0.0, 0.0)
        
//        rootNode.addChildNode(earthNode)
//        earthNode.addChildNode(helperNode)
        
        
//        rootNode.addChildNode(helperNodeSunEarth)
//        helperNodeSunEarth.addChildNode(earthNode)
//        earthNode.addChildNode(helperNode)

        
        helperNodeSunEarth.addChildNode(earthNode)
        earthNode.addChildNode(helperNode)
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
    
    //To animate all the nodes in the whole scene
    func animateEarthScene() {
        
        sunNodeRotation   = revolve(node: sunNode, value: sunNodeRotation, increase: sunNodeRotationSpeed)
        earthNodeRotation = revolve(node: earthNode, value: earthNodeRotation, increase: earthNodeRotationSpeed)
        moonNodeRotation  = revolve(node: moonNode, value: moonNodeRotation, increase: moonNodeRotationSpeed)
        
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = (CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear))
        
        SCNTransaction.animationDuration = 1
        SCNTransaction.completionBlock = {
            self.animateEarthScene()
        }
        
        sunNode.rotation   = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(sunNodeRotation))
        earthNode.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(earthNodeRotation))
        moonNode.rotation  = SCNVector4(x: 10.0, y: 10.0, z: 10.0, w: Float(moonNodeRotation))
        
        SCNTransaction.commit()
    }
    
    // Revolves moon around Earth
    func animateMoon() {
        
        let rotation = SCNAction.rotateBy(x: 0, y: 8, z: 9, duration: .infinity)
        helperNode.runAction(rotation)
    }
    
    
    func getRootNode() -> SCNNode {
        
        rootNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        
        return rootNode
    }
    
    func getEarthNode() -> SCNNode {
        
        return earthNode
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
        earthScene.animateEarthScene()
        //        earthScene.animateMoon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getRootNode() -> SCNNode {
        return earthScene.getRootNode()
    }
    
    
    func getEarthNode() -> SCNNode {
        return earthScene.getEarthNode()
    }
}

let usingMac = false

if usingMac {
    PlaygroundPage.current.liveView = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: 800.0, height: 800.0))
} else {
    PlaygroundPage.current.liveView = MyARTest()
}



PlaygroundPage.current.needsIndefiniteExecution = true
