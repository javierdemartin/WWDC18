// Apple's WWDC18 Scholarship Submission by Javier de Martín

// Planet assets used under Attribution 4.0 (https://www.solarsystemscope.com/textures)
// Following this tuto: https://www.appcoda.com/arkit-horizontal-plane/

import ARKit
import UIKit
import SceneKit
import PlaygroundSupport

let usingMac  = false // If on Mac deactivates AR and shows a SCNView
let isInDebug = true // 
var alreadyAdded = false
var userReadInstructions = false // User has accepted the instructions
var initialScreenAdded = false // Checks if the view with the instructions has been presented to the user

let planetList = ["mercury", "venus", "earth", "mars", "jupiter", "saturn", "uranus", "neptune"]

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

// ARKit
//---------------------------------------------------------------

// Main ARKIT ViewController
class ViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate, UIScrollViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var solarSystem : PlanetaryView!
    var presentedList = false
    var scrollView: UIScrollView!
    
    @objc func addSolarSystemTosceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
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
    
    @IBAction func touchedPlanet(sender: UIButton) {
        
        var touched = ""
        
        for i in 0...planetList.count {
            
            if i == sender.tag {
                print("Touched \(i) \(planetList[i])")
                
                touched = planetList[i]
            }
            
        }
        
        
        
        dump(sceneView.scene.rootNode.childNodes)
        
        for i in sceneView.scene.rootNode.childNodes {
            
//            dump("> \(i.childNodes)")
            
            for j in i.childNodes {
//                print(j.childNodes)
                
                // Got all child nodes
                for k in j.childNodes {
                    print(k.name)
                    
                    print(planetList)
                    
                    if k.name != nil {
                        print(k.name!)
                        
                        if touched != k.name! {
                            print("EHEHE")
                            k.opacity = 0.5
                        } else {
                            k.opacity = 1.0
                        }
                        
                    }
                }
            }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self as ARSCNViewDelegate
        
        sceneView.scene.rootNode // Create a new scene
        sceneView.autoenablesDefaultLighting = true // Add ligthing
        
        if isInDebug {
            sceneView.showsStatistics = true
            solarSystem = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
            
            self.sceneView.scene.rootNode.addChildNode(solarSystem.getRootNode())
        }
        
        addTapGestureToSceneView()
        
        
        
    }
    

    // Adds a UITapGestureRecognizer to add the Solar System projection when the user taps on a detected surface
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addSolarSystemTosceneView))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        
        presentStuff()
        presentList()
        
    }
    
    func presentList() {
        
        if !presentedList && userReadInstructions {
            
            let scrollViewHeight: CGFloat = 100.0
            let offset: CGFloat = 10.0
            
            scrollView = UIScrollView(frame: CGRect(x: 0.0, y: self.view.frame.height - scrollViewHeight, width: self.view.frame.width, height: scrollViewHeight))
            scrollView.contentSize = CGSize(width: offset + ( (scrollViewHeight - 20.0 + offset) * CGFloat(planetList.count + 1)), height: 80.0)
            
            scrollView.backgroundColor = UIColor(red: 0/255, green: 209/255, blue: 209/255, alpha: 0.2)
            
            scrollView.isScrollEnabled = true
            
            let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width / 2, height: scrollViewHeight))
            

            scrollView.addSubview(containerView)
            self.view.addSubview(scrollView)
            
            for i in 0...planetList.count {
                let eButton = UIButton(frame: CGRect(x: offset + ( (scrollViewHeight - 20.0 + offset) * CGFloat(i)), y: 10.0, width: scrollViewHeight - 20.0, height: scrollViewHeight - 20.0))
                eButton.backgroundColor = UIColor.random()
                eButton.layer.cornerRadius = eButton.frame.height / 2
                eButton.tag = i
                eButton.addTarget(self, action: #selector(touchedPlanet), for: .touchUpInside)
                
                print("Added target")
                
                containerView.addSubview(eButton)
            }
            
            presentedList = true
         }
    }
    
    // Shows initial screen with instructions
    func presentStuff() {
        
        if !userReadInstructions && !initialScreenAdded {
            
            print(self.view.frame)
            
            let presentationView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: sceneView.frame.width, height: sceneView.frame.height))
            presentationView.tag = 100
            presentationView.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 0.2)
            
            let title = UILabel(frame: CGRect(x: 10, y: self.view.frame.height / 5, width: self.view.frame.width - 10, height: 50))
            title.text = "PlanetARium"
            title.textColor = UIColor.white
            title.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
            title.textAlignment = .left
            
            print(self.view.frame)
            print(sceneView.frame)
            print(sceneView.bounds)
            
            let subtitle = UILabel(frame: CGRect(x: 10.0, y: (2 * self.view.frame.height) / 5, width: self.view.frame.width , height: 100.0))
            
            subtitle.text = "Once your device detects a flat surface tap it to discover the Solar System and learn how the planets move"
            subtitle.numberOfLines = 10
            subtitle.textColor = UIColor.white
            subtitle.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            subtitle.textAlignment = .left
            
            print(subtitle.frame)
            
//            let acceptButton = UIButton(frame: CGRect(x: self.view.frame.width / 2 - 40.0, y: sceneView.frame.height - 300.0, width: 80.0, height: 80.0))
            let acceptButton = UIButton(frame: CGRect(x: 20.0, y: 20.0, width: 80.0, height: 80.0))
            acceptButton.tag = 11
            acceptButton.setTitle("👍🏼", for: .normal)
            acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .regular)
            acceptButton.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 0.5)
            acceptButton.layer.cornerRadius = acceptButton.frame.height/2
            acceptButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            
            self.view.addSubview(presentationView)
            presentationView.addSubview(title)
            presentationView.addSubview(subtitle)
            presentationView.addSubview(acceptButton)
            
            initialScreenAdded = true
        }
    }
    
    // This protocol method gets called every time the scene view’s session has a new ARAnchor added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor(red: 10/255, green: 200/255, blue: 255/255, alpha: 0.2)
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    // This method gets called every time a SceneKit node’s properties have been updated to match its corresponding anchor.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}



// SceneKit
//---------------------------------------------------------------

class EarthScene: SCNScene  {
    
    // List of all the displayed planets and the radius of each one
    let planetsRadius : [String : Double] = ["mercury" : 3, 
                                             "venus" : 5, 
                                             "earth" : 7, 
                                             "mars" : 9, 
                                             "jupiter" : 11,
                                             "saturn" : 13, 
                                             "uranus" : 15, 
                                             "neptune" : 17]
    
    // Speed rotation of a planet on days
    var planetsRotations : [String : CGFloat] = ["mercury" : 1/87.969,
                                                 "venus" : 1/224.7, 
                                                 "earth" : 1/365.25, 
                                                 "mars" : 1/320, 
                                                 "jupiter" : 1/(11.8618 * 365), 
                                                 "saturn" : 1/10759, 
                                                 "uranus" : 1/30688.5, 
                                                 "neptune" : 1/60182]
    
    // Sun
    let sunNode: SCNNode              = SCNNode()
    let sunNodeRotationSpeed: CGFloat = CGFloat(0.2) //CGFloat(Double.pi/6)
    var sunNodeRotation: CGFloat      = 0
    let sunRadius : CGFloat             = 2 // Real en UA
    
    // Observer
    let observerNode = SCNNode()
    
    override init()  {
        
        super.init()
        
        addStar(name: "sun")
        addPlanet(name: "mercury", speed: planetsRotations["mercury"]! * 20, planetRadius: 0.2)
        addPlanet(name: "venus", speed: planetsRotations["venus"]! * 20, planetRadius: 0.5)
        addPlanet(name: "earth", speed: planetsRotations["earth"]! * 20, planetRadius: 1)
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
        
        observerNode.camera = SCNCamera()
        observerNode.position = SCNVector3(x:0, y: 10, z: 0) //Set up initial camera's position
        observerNode.name = "Observer Node"
        
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
        
        let observerGeometry = SCNSphere(radius: sunRadius)
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
        
        
        let earthMaterial              = SCNMaterial()
//        earthMaterial.ambient.contents = UIColor(white: 0.7, alpha: 0)
        earthMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
        
        earthMaterial.specular.intensity = 1
        earthMaterial.shininess = 0.05
        earthMaterial.multiply.contents = UIColor(white: 0.7, alpha: 1.0)
        
        let earthGeometry = SCNSphere(radius: CGFloat(planetRadius))
        earthGeometry.firstMaterial = earthMaterial
        
        nextNode.geometry = earthGeometry
        nextNode.position = SCNVector3(planetsRadius[name]!, 0.0, 0.0)
        
        
        
        planetsRotations[name]!   = revolve(node: nextNode, value: planetsRotations[name]!, increase: 200)
        nextNode.rotation  = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(planetsRotations[name]!))
        nextNode.name = name
        
        rootNode.addChildNode(helperAuxNode)
        helperAuxNode.addChildNode(nextNode)
        
        myAnimation(nextNode: helperAuxNode, rotation: planetsRotations[name]!, speed: speed)
        myAnimation(nextNode: nextNode, rotation: planetsRotations[name]!, speed: speed * 100)
    }
    
    // Traslation movement of the planet arount the star
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
        
        allowsCameraControl = true //Allow user to adjust viewing angle
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

// Playground execution
if usingMac {
    PlaygroundPage.current.liveView = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: 800.0, height: 800.0))
} else {
    PlaygroundPage.current.liveView = ViewController()
}

PlaygroundPage.current.needsIndefiniteExecution = true
