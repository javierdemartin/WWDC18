
// Apple's WWDC18 Scholarship Submission by Javier de Martín
// Planet assets used under Attribution 4.0 (https://www.solarsystemscope.com/textures)

import ARKit
import UIKit
import SceneKit
import PlaygroundSupport

// Instructions
//
// 1️⃣ Hold your iPad and move it around until it
// finds a flat surface.
// 2️⃣ Tap on the blue area to place the Solar System
// 3️⃣ Use the list to select a planet and know where it is. Tap it again to see all the planets again 
// 🚀 Enjoy!


let isInDebug = false // Shows auxiliary constraints to debug ARKit scene 
var alreadyAdded = false
var userReadInstructions = false // User has accepted the instructions
var initialScreenAdded = false // Checks if the view with the instructions has been presented to the user



// Uncomment planets to add them, my current iPad can't render all of them at the same time due to lack of memory.
let planetList = ["mercury", "venus", "earth", "mars", "jupiter"] //, "saturn", "uranus", "neptune"]

// ARKit
//---------------------------------------------------------------

// Main ARKIT ViewController
class ViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate, UIScrollViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var solarSystem : PlanetaryView!
    var presentedList = false
    var scrollView: UIScrollView!
    var previouslyTouchedButton = -1
    
    @objc func addSolarSystemTosceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        if !alreadyAdded {
            // Only adds the UIScrollView once a surface has been tapped
            
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
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        
        if let viewWithTag = self.view.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
                userReadInstructions = true
            
            addPlanetScrollList()
        }
    }
    
    @IBAction func touchedPlanet(sender: UIButton) {
        
        let touched = planetList[sender.tag]
        
        for i in self.view.subviews {
            
            print(i.tag)
            
            for j in i.subviews {
                print(j.tag)
                
                for k in j.subviews {
                    print(k.tag)
                    
                    if previouslyTouchedButton == sender.tag {
                        
                        for a in sceneView.scene.rootNode.childNodes {
                            
                            for b in a.childNodes {
                                
                                // Got all child nodes
                                for c in b.childNodes {
                                    
                                    c.opacity = 1.0
                                }
                            }
                        }
                    } else  {
                        
                        for i in sceneView.scene.rootNode.childNodes {
                            
                            for j in i.childNodes {
                                
                                // Got all child nodes
                                for k in j.childNodes {
                                    
                                    if k.name != nil {
                                        print(k.name!)
                                        
                                        if touched != k.name! {
                                            
                                            k.opacity = 0.5
                                        } else {
                                            k.opacity = 1.0
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        print("Touched \(sender.tag) \(planetList[sender.tag])")
        
        previouslyTouchedButton = sender.tag
    }
    
    
    override func loadView() {
        
        sceneView = ARSCNView()
        sceneView.delegate = self
        
        if isInDebug {
            sceneView.showsStatistics = true
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
        
//        sceneView.scene.rootNode // Create a new scene
        sceneView.autoenablesDefaultLighting = true // Add ligthing
        
//        if isInDebug {
//            sceneView.showsStatistics = true
//            solarSystem = PlanetaryView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height))
//
//            self.sceneView.scene.rootNode.addChildNode(solarSystem.getRootNode())
//        }
        
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
        
        presentInstructionsToUser()
    }
    
    // Adds a UIScrollView to the bottom of the screen 
    func addPlanetScrollList() {
        
        if !presentedList && userReadInstructions {
            
            let scrollViewHeight: CGFloat = 140.0
            let offset: CGFloat = 10.0
            
            scrollView = UIScrollView(frame: CGRect(x: 0.0, y: self.view.frame.height - scrollViewHeight, width: self.view.frame.width, height: scrollViewHeight))
            scrollView.contentSize = CGSize(width: offset + ( (scrollViewHeight - 20.0 + offset) * CGFloat(planetList.count + 1)), height: 80.0)
            
            scrollView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
            scrollView.isScrollEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            
            let containerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: offset + ( (scrollViewHeight - 20.0 + offset) * CGFloat(planetList.count + 1)), height: scrollViewHeight))

            scrollView.addSubview(containerView)
            self.view.addSubview(scrollView)
            
            // Adds a button for every planet there is
            for i in 0..<planetList.count {
                let planetButton = UIButton(type: .custom)
                planetButton.frame = CGRect(x: offset + ( (scrollViewHeight - 20.0 + offset) * CGFloat(i)), y: 10.0, width: scrollViewHeight - 50.0, height: scrollViewHeight - 50.0)
                
                planetButton.addTarget(self, action: #selector(touchedPlanet), for: .touchUpInside)
                planetButton.clipsToBounds = true
                planetButton.layer.cornerRadius = planetButton.frame.height / 2
                planetButton.tag = i
                
                let planetLabel = UILabel(frame: CGRect(x: offset + ( (scrollViewHeight - 20.0 + offset) * CGFloat(i)), y: 40.0, width: scrollViewHeight - 50.0, height: scrollViewHeight + 20.0))
                planetLabel.text = planetList[i].capitalized
                planetLabel.textAlignment = .center
                planetLabel.textColor = UIColor.white
                
                print("Added button for \(planetList[i]) \(i)")
                
                if let image = UIImage(named: "\(planetList[i]).jpg") {
                    planetButton.setImage(image, for: .normal)
                }
                
                containerView.addSubview(planetButton)
                containerView.addSubview(planetLabel)
            }
            
            presentedList = true
         }
    }
    
    // Shows initial screen with instructions of how the playground works
    // View hierarchy
    // view (UIView)
    // -- presentationView (UIView)
    // ---- title (UILabel)
    // ---- subtitle (UILabel)
    func presentInstructionsToUser() {
        
        if !userReadInstructions && !initialScreenAdded {
            
            let presentationView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: sceneView.frame.width, height: sceneView.frame.height))
            presentationView.tag = 100
            presentationView.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 0.2)
            
            let title = UILabel(frame: CGRect(x: 10, y: self.view.frame.height / 5, width: self.view.frame.width - 10, height: 50))
            title.text = "PlanetARium"
            title.textColor = UIColor.white
            title.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
            title.textAlignment = .left
            
            let subtitle = UILabel(frame: CGRect(x: 10.0, y: title.frame.maxY + 20.0, width: self.view.frame.size.width / 2 - 20.0 , height: 300.0))
            
            subtitle.text = "1️⃣ Find a flat surface\n\n2️⃣ Tap the surface\n\n🚀 Tap the screen to continue"
            subtitle.numberOfLines = 0
            subtitle.textColor = UIColor.white
            subtitle.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            subtitle.textAlignment = .left
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonClicked))
            presentationView.addGestureRecognizer(tapGesture)
            
            self.view.addSubview(presentationView)
            presentationView.addSubview(title)
            presentationView.addSubview(subtitle)
            
            initialScreenAdded = true
            
            
        }
        
    }
    
    // This protocol method gets called every time the scene view’s session has a new ARAnchor added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !alreadyAdded {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            plane.materials.first?.diffuse.contents = UIColor(red: 10/255, green: 200/255, blue: 255/255, alpha: 0.1)
            
            let planeNode = SCNNode(geometry: plane)
            
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
        }
    }
    
    // This method gets called every time a SceneKit node’s properties have been updated to match its corresponding anchor.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        if !alreadyAdded {
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
}

// SceneKit
//---------------------------------------------------------------

class PlanetsScene: SCNScene  {
    
    // List of all the displayed planets and the radius of each orbit
    let planetsRadius : [String : CGFloat] = ["mercury" : 3,
                                             "venus" : 5,
                                             "earth" :  7,
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
    
    let radiuses : [String : CGFloat] = ["mercury" : 0.2,
                                              "venus" : 0.6,
                                              "earth" :  1,
                                              "mars" : 0.75,
                                              "jupiter" : 0.5,
                                              "saturn" : 1.5,
                                              "uranus" : 0.7,
                                              "neptune" : 0.2]
    
    // Sun
    let sunNode: SCNNode              = SCNNode()
    let sunNodeRotationSpeed: CGFloat = CGFloat(0.2)
    var sunNodeRotation: CGFloat      = 0
    let sunRadius : CGFloat           = 2
    
    override init()  {
        
        super.init()
        
        addStar(name: "sun")
        
        for planet in planetList {
            
            addPlanet(name: planet, speed: planetsRotations[planet]! * 10, planetRadius: radiuses[planet]!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
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
    
    // Hierarchy
    // -- rootNode (SCNNode)
    // ---- sunNode (SCNNode)
    func addStar(name: String) {
        
        let sunMaterial = SCNMaterial()
        
        sunMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
        
        let sunGeometry = SCNSphere(radius: sunRadius)
        sunGeometry.firstMaterial = sunMaterial
        
        sunNode.position = SCNVector3(0, 0, 0)
        sunNode.geometry = sunGeometry
        
        sunNodeRotation   = revolve(node: sunNode, value: sunNodeRotation, increase: 1)
        sunNode.rotation   = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(sunNodeRotation))
        
        rootNode.addChildNode(sunNode)
        
        myAnimation(nextNode: sunNode, rotation: sunNodeRotation, speed: 1)
    }
    
    // Hierarchy
    // -- rootNode (SCNNode)
    // ---- helperNode (SCNNode)
    //          Allows traslation movement of the planet
    // ------ planetNode (SCNNode)
    //          Allows rotation movement of the planet
    func addPlanet(name: String, speed: CGFloat, planetRadius : CGFloat) {
        
        let planetNode = SCNNode()
        let helperNode = SCNNode()
        
        let planetMaterial              = SCNMaterial()
        planetMaterial.diffuse.contents = UIImage(named: "\(name).jpg")
        
        let planetGeometry = SCNSphere(radius: CGFloat(planetRadius))
        planetGeometry.firstMaterial = planetMaterial
        
        planetNode.geometry = planetGeometry
        planetNode.position = SCNVector3(planetsRadius[name]!, 0.0, 0.0)
        
        planetsRotations[name]!   = revolve(node: planetNode, value: planetsRotations[name]!, increase: 1)
        planetNode.rotation  = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: Float(planetsRotations[name]!))
        planetNode.name = name
        
        rootNode.addChildNode(helperNode)
        helperNode.addChildNode(planetNode)
        
        myAnimation(nextNode: helperNode, rotation: planetsRotations[name]!, speed: speed)
        myAnimation(nextNode: planetNode, rotation: planetsRotations[name]!, speed: speed * 100)
    }
    
    // Traslation movement of the planet arount the star
    func myAnimation(nextNode: SCNNode, rotation: CGFloat, speed : CGFloat) {
        
        if userReadInstructions {
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
}

//SCNView for presenting the Scene
class PlanetaryView: SCNView {
    
    let earthScene: PlanetsScene = PlanetsScene()
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: nil)
        
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

// Playground execution
PlaygroundPage.current.liveView = ViewController()

PlaygroundPage.current.needsIndefiniteExecution = true
