// WWDC18 Scholarship Submission by Javier de Martín

// Planet assets used under Attribution 4.0 (https://www.solarsystemscope.com/textures)

// TODO : Add tap gesture recognizers on each planet to display information

// Following this tuto: https://www.appcoda.com/arkit-horizontal-plane/

import ARKit
import UIKit
import SceneKit
import PlaygroundSupport

let usingMac = true
let isInDebug = false

// ARKit
//---------------------------------------------------------------

// Main ARKIT ViewController
class MyARTest : UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var solarSystem : PlanetaryView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the views delegate
        sceneView.delegate = self as ARSCNViewDelegate
        sceneView.showsStatistics = true
       
        sceneView.scene.rootNode // Create a new scene
        sceneView.autoenablesDefaultLighting = true // Add ligthing
        
        solarSystem = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        
        self.sceneView.scene.rootNode.addChildNode(solarSystem.getRootNode())
    }
    
     override func loadView() {

        sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
        // Set the view's delegate
        sceneView.delegate = self
        
        if isInDebug {
            sceneView.debugOptions = [.showBoundingBoxes, .showCameras, .showConstraints]
        }

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
    
    let planets : [String : Double] = ["mercury" : 2, "venus" : 5, "earth" : 7, "mars" : 9, "jupiter" : 11, "saturn" : 13, "uranus" : 15, "neptune" : 17]
    
    var planetsRotations : [String : CGFloat] = ["mercury" : 4, "venus" : 8, "earth" : 12, "mars" : 15, "jupiter" : 18, "saturn" : 22, "uranus" : 25, "neptune" : 28]
    
    
    // Moon
    let moonNode : SCNNode             = SCNNode()
    let moonNodeRotationSpeed: CGFloat = 1 //CGFloat(Double.pi/8)
    var moonNodeRotation: CGFloat      = 0
    let moonRadius : Float             = 0.5 // 0.000011614
    
    // Earth
    let earthNode: SCNNode = SCNNode()
    var earthNodeRotation: CGFloat = 0
    let earthNodeRotationSpeed: CGFloat = 0.25 //CGFloat(0.1965) //CGFloat(Double.pi/40)
    let earthRadius : Float = 1 // 0.00004258756 Real
    
    // Sun
    let sunNode: SCNNode              = SCNNode()
    let sunNodeRotationSpeed: CGFloat = CGFloat(0.2) //CGFloat(Double.pi/6)
    var sunNodeRotation: CGFloat      = 0
    let sunRadius : Float             = 2 // Real en UA
    
    // Observer
    let observerNode: SCNNode = SCNNode()
    let helperNode            = SCNNode()
    let helperNodeSunEarth    = SCNNode()
    
    override init()  {
        
        super.init()
        
        addStar(name: "sun")
        addPlanet(name: "mercury", speed: 10, radius: 0.2)
        addPlanet(name: "venus", speed: 2, radius: 0.5)
        addPlanet(name: "earth", speed: 3, radius: 1)
        addPlanet(name: "mars", speed: 4, radius: 0.75)
        addPlanet(name: "jupiter", speed: 5, radius: 0.5)
        addPlanet(name: "saturn", speed: 6, radius: 1.5)
        addPlanet(name: "uranus", speed: 7, radius: 0.7)
        addPlanet(name: "neptune", speed: 8, radius: 0.2)
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
        
        sunNode.position = SCNVector3(10, 0, 0)
        sunNode.geometry = observerGeometry
        sunNode.light = observerLight
        
        rootNode.addChildNode(sunNode)
//        sunNode.addChildNode(helperNodeSunEarth)
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

    func getRootNode() -> SCNNode {
        
        rootNode.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        return rootNode
    }
    
    func getEarthNode() -> SCNNode {
        
        return earthNode
    }
    
    // New methods
    //---------------------------------------------------------
    
    
    func addStar(name: String) {
    
        let observerMaterial = SCNMaterial()
//        observerMaterial.specular.intensity = 1.0
        observerMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
        
        let observerGeometry = SCNSphere(radius: 1.5)
        observerGeometry.firstMaterial = observerMaterial
        
        let observerLight = SCNLight()
        observerLight.type = SCNLight.LightType.ambient
        observerLight.color = UIColor(white: 0.15, alpha: 1.0)
        
        sunNode.position = SCNVector3(0, 0, 0)
        sunNode.geometry = observerGeometry
        sunNode.light = observerLight
        
        sunNodeRotation   = revolve(node: sunNode, value: sunNodeRotation, increase: 0.2)
        sunNode.rotation   = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(sunNodeRotation))
        
        rootNode.addChildNode(sunNode)
        sunNode.addChildNode(helperNode)
        
        myAnimation(nextNode: sunNode, rotation: sunNodeRotation, speed: sunNodeRotationSpeed)
        
    }
    
    
    
//    func addPlanet(name: String, speed: CGFloat) {
//
//        let nextNode = SCNNode()
//
//        let earthMaterial              = SCNMaterial()
//        earthMaterial.ambient.contents = UIColor(white: 0.7, alpha: 1.0)
//        earthMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
//
//        earthMaterial.specular.intensity = 1
//        earthMaterial.shininess = 0.05
//        earthMaterial.multiply.contents = UIColor(white: 0.7, alpha: 1.0)
//
//        //Earth is a sphere with radius 5
//        let earthGeometry = SCNSphere(radius: CGFloat(earthRadius))
//        earthGeometry.firstMaterial = earthMaterial
//
//        nextNode.geometry = earthGeometry
//        nextNode.position = SCNVector3(planets[name]!, 0.0, 0.0)
//
//
//
//        planetsRotations[name]!   = revolve(node: nextNode, value: planetsRotations[name]!, increase: 0.2)
//        nextNode.rotation  = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(planetsRotations[name]!))
//
//        sunNode.addChildNode(helperNode)
//        helperNode.addChildNode(nextNode)
//
//        ////////////
//
//        myAnimation(nextNode: nextNode, rotation: planetsRotations[name]!)
//    }

    
    func addPlanet(name: String, speed: CGFloat, radius : CGFloat) {
        
        let nextNode = SCNNode()
        let helperAuxNode = SCNNode()
        
        let earthMaterial              = SCNMaterial()
        earthMaterial.ambient.contents = UIColor(white: 0.7, alpha: 1.0)
        earthMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
        
        earthMaterial.specular.intensity = 1
        earthMaterial.shininess = 0.05
        earthMaterial.multiply.contents = UIColor(white: 0.7, alpha: 1.0)
        
        //Earth is a sphere with radius 5
        let earthGeometry = SCNSphere(radius: CGFloat(radius))
        earthGeometry.firstMaterial = earthMaterial
        
        nextNode.geometry = earthGeometry
        nextNode.position = SCNVector3(planets[name]!, 0.0, 0.0)
        
        
        
        planetsRotations[name]!   = revolve(node: nextNode, value: planetsRotations[name]!, increase: speed)
        nextNode.rotation  = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(planetsRotations[name]!))
        
        rootNode.addChildNode(helperAuxNode)
        helperAuxNode.addChildNode(nextNode)
        
        ////////////
        
        myAnimation(nextNode: helperAuxNode, rotation: planetsRotations[name]!, speed: speed)
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
    
    //---------------------------------------------------------
    
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
    
    
    func getEarthNode() -> SCNNode {
        return earthScene.getEarthNode()
    }
}

if usingMac {
    PlaygroundPage.current.liveView = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: 800.0, height: 800.0))
} else {
    PlaygroundPage.current.liveView = MyARTest()
}



PlaygroundPage.current.needsIndefiniteExecution = true
