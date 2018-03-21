// ARSCNView test

import ARKit
import UIKit
import SceneKit
import PlaygroundSupport

//////////////////////////////////////////////////////
//
//
// ARKit
//
//////////////////////////////////////////////////////

// Main ARKIT ViewController
class MyARTest : UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the views delegate
        sceneView.delegate = self as! ARSCNViewDelegate
       // show statistics such as fps and timing information
       sceneView.showsStatistics = true
       // Create a new scene
       sceneView.scene.rootNode
       // Add ligthing
       sceneView.autoenablesDefaultLighting = true

     //  add new node to root node
     self.sceneView.scene.rootNode.addChildNode(EarthView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0)).getRootNode())

     // Add an scaleSlider button
     weak var scaleSlider: UISlider! {
         didSet {
            scaleSlider.transform =  CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
     }
     scaleSlider = UISlider()
     scaleSlider.addTarget(self, action: #selector(updateScaleWithSlider(_:)), for: .touchUpInside)
     scaleSlider.minimumValue = 0
     scaleSlider.maximumValue = 10
        // add scaleSlider to view
    sceneView.addSubview(scaleSlider)

    // Auto Layout
    scaleSlider.translatesAutoresizingMaskIntoConstraints = true
  }

 override func loadView() {

    sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
    // Set the view's delegate
    sceneView.delegate = self

    let config = ARWorldTrackingConfiguration()
    config.planeDetection = .horizontal

    // Now we'll get messages when planes were detected...
    sceneView.session.delegate = self

    self.view = sceneView
    sceneView.session.run(config)

 }

 func scaleNode(value: Float) {
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 1
    self.sceneView.scene.rootNode.scale = SCNVector3(value, value, value)
    
    SCNTransaction.commit()
 }

@IBAction func updateScaleWithSlider(_ sender: UISlider) {
    guard let slider = sender as? UISlider else { return }
    scaleNode(value: slider.value)
 }

}


//////////////////////////////////////////////////////
//
//
// SceneKit
//
//////////////////////////////////////////////////////

class EarthScene: SCNScene  {
    
    
    // Moon
    let moonNode : SCNNode = SCNNode()
    let moonNodeRotationSpeed: CGFloat = CGFloat(Double.pi/8)
    var moonNodeRotation: CGFloat = 0
    let moonRadius : Float = 0.5 // 0.000011614
    
    // Earth
    let earthNode: SCNNode = SCNNode()
    var earthNodeRotation: CGFloat = 0
    let earthNodeRotationSpeed: CGFloat = CGFloat(0.1965) //CGFloat(Double.pi/40)
    let earthRadius : Float = 1 // 0.00004258756 Real
    
    // Sun
    let sunNode: SCNNode = SCNNode()
    let sunNodeRotationSpeed: CGFloat  = CGFloat(1.997) //CGFloat(Double.pi/6)
    var sunNodeRotation: CGFloat = 0
    let sunRadius : Float = 2 // Real en UA
    
    
    // Observer
    let observerNode: SCNNode = SCNNode()
    let helperNode  = SCNNode()
    
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
        observerNode.position = SCNVector3(x:2, y: 2, z: 10)
        
        rootNode.addChildNode(observerNode)
        
        let observerMaterial = SCNMaterial()
        observerMaterial.specular.intensity = 1.0
        observerMaterial.diffuse.contents = UIImage(named: "sun.jpg")
        
        let auxNode = SCNNode()
        auxNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        let observerGeometry = SCNSphere(radius: 2)
        observerGeometry.firstMaterial = observerMaterial
        
        
        let observerLight = SCNLight()
        observerLight.type = SCNLight.LightType.ambient
        observerLight.color = UIColor(white: 0.15, alpha: 1.0)
        
        
        auxNode.geometry = observerGeometry
        //        auxNode.light = observerLight
        
        
        
        rootNode.addChildNode(auxNode)
        
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
        
        //Set up sunlights postion
        let sunNodeLight = SCNLight()
        sunNodeLight.type = SCNLight.LightType.ambient
        sunNodeLight.intensity = 0.8
        
        sunNode.light = sunNodeLight
        
        // Set up roation vector
        sunNode.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(CGFloat(sunNodeRotation)))
        rootNode.addChildNode(sunNode)
        
    }
    
    func setUpEarth() {
        
        let earthMaterial = SCNMaterial()
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
        
        earthNode.addChildNode(helperNode)
        rootNode.addChildNode(earthNode)
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
        moonNode.rotation  = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(moonNodeRotation))
        
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
}

//SCNView for presenting the Scene
class EarthView: SCNView {
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
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
        
        
    }
    
    func getRootNode() -> SCNNode {
        
        return earthScene.getRootNode()
    }
}


PlaygroundPage.current.liveView = MyARTest()
PlaygroundPage.current.needsIndefiniteExecution = true
