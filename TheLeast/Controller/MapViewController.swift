//
//  MapViewController.swift
//  TheList
//
//  Created by Ofir Elias on 17/12/2018.
//  Copyright © 2018 Ofir Elias. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Lottie
import Alamofire
import SwiftyJSON


protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}


open class MapViewController: UIViewController, CheapOrTippDelegate, UserInfoDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationInfo: UILabel!
    @IBOutlet weak var centerPinImag: UIImageView!
    @IBOutlet weak var cheapedButton: UIButton!
    @IBOutlet weak var tippedButton: UIButton!
    @IBOutlet weak var uiContainer: UIView!
    @IBOutlet weak var currentLocationConstrain: NSLayoutConstraint!
    @IBOutlet weak var searchLook: UINavigationItem!
    @IBOutlet weak var userInfoView: UIView!
    
    //MARK: Properties
    var centerLocationAddress = CustomerItem()
    var hasTipped = Bool()
    var customerList = [CustomerItem]()
    let searchedCustomerAddress = CustomerItem()
    
    var selectedPin:MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil
    
    var customerLocation = CLLocationCoordinate2D()
    var curentLocation = CustomerItem()
    
    let regionInMeters = 1000.0
    let locationManager = CLLocationManager()
    
    var previousLocation: CLLocation?
    var firstLocation = Location()
    
    var animationView = AnimationView()
    let myView = UIView()
    
    var URL = "https://frozen-meadow-31076.herokuapp.com/api/customers"
    
    let alertService = AlertService()

    
    @IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .began {
            userInfoView.isHidden = true
        }
    }
    
    
    ////////////////MARK: ViewDidLoad
    override open func viewDidLoad(){
        super.viewDidLoad()
        
        //Get data from server
        getCustomersData()
        
        //Buttons Apperiance
        uiCheapButton(button: cheapedButton)
        uiTipButton(button: tippedButton)
        
        //Container Apperiance
        uiContainerDesign()
        
        //Check for Authorization, if Authorized then it setup the location manager
        checkLocationServise()
        
        //Navigation Bar Transparent
        navegationBarDesign()
        
        //Adding Search Bar to Map View
        addSearchBarToMapView()
        
    }
    
    
    /// MARK: Database funcs
    ///Get all customers from database
    func getCustomersData(){
        var list = [CustomerItem]()
        Alamofire.request(URL, method: .get).responseJSON {
            respone in
            if respone.result.isSuccess{
                if let customersJSON: [JSON] = JSON(respone.result.value!).array{
                    for customer in customersJSON{
                        let customerData = CustomerItem()
                        customerData.id = customer["_id"].stringValue
                        customerData.city = customer["city"].stringValue
                        customerData.streetName = customer["streetName"].stringValue
                        customerData.doorNumber = customer["doorNumber"].stringValue
                        customerData.houseNumber = customer["houseNumber"].stringValue
                        customerData.cheapped = customer["cheapped"].intValue
                        customerData.tipped = customer["tipped"].intValue
                        customerData.customerIsCheap = customer["customerIsCheap"].boolValue
                        print(customerData.id)
                        list.append(customerData)
                    }
                }
                self.customerList = list
            }else {
                print("Error \(String(describing: respone.result.error))")
            }
        }.resume()
    }
    
    
    //Add customer to database
    func postCustomerData(url: String, customer: CustomerItem, isTipped: Bool){
        loginAnimation()
        let customerParams: [String: Any] =
            [
            "city": customer.city,
            "streetName": customer.streetName,
            "houseNumber": customer.houseNumber,
            "doorNumber": customer.doorNumber,
            "isTipped": isTipped
            ]
        
        Alamofire.request(url, method: .post, parameters: customerParams, encoding: JSONEncoding.default).responseString {
            respone in
            if respone.result.isSuccess{
                self.stopAnimation()
                switch respone.response?.statusCode {
                case 200 :
                    print("New customer added")
                    self.checkAnimation()
                    self.getCustomersData()
                    print(self.customerList.count)
                case 500:
                    print("somthing is missing: \(respone.description)")
                case 400:
                    print(respone.description)
                    print("Customer exist updating")
                    self.updateCustomerData(url: url, customer: customerParams, isTipped: isTipped)
                default:
                    break
                }
            }
        }
    }
    
    
    //Update customer
    func updateCustomerData(url: String, customer: [String: Any], isTipped: Bool ) {
        loginAnimation()
        Alamofire.request(url + "/update", method: .put, parameters: customer, encoding: JSONEncoding.default).responseString {
            respone in
            if respone.result.isSuccess{
                self.stopAnimation()
                switch respone.response?.statusCode {
                case 200:
                    self.checkAnimation()
                    self.getCustomersData()
                    print("Customer has been updated")
                case 400:
                    print("wrong input")
                default:
                    print("Somthing went wrong")
                }
            }else{
                print("Error: \(respone.description)")
            }
            self.getCustomersData()
        }
    }
    

    
    //MARK: Buttons Action
    @IBAction func cheapedButton(_ sender: UIButton) {
        tippAlert(title: "Customer Cheapped", isTipped: false, newCustomer: centerLocationAddress)
        hasTipped = false
    }
    
    @IBAction func tippedButton(_ sender: UIButton) {
        tippAlert(title: "Customer Tipped", isTipped: true, newCustomer: centerLocationAddress)
        hasTipped = true
    }
    
    @IBAction func myLocationButton(_ sender: UIButton) {
        centerViewOnUserLocation()
    }
    

    
    
    
    @IBAction func userInfoButton(_ sender: Any) {
        self.present(alertService.UserInfoAlert(), animated: true, completion: nil)
    }
    
    func addButtonTapped(textFieldValue: String) {
        if textFieldValue.count > 0 {
            centerLocationAddress.doorNumber = textFieldValue
            postCustomerData(url: self.URL, customer: centerLocationAddress, isTipped: hasTipped)
        }
        
    }
    
    func logoutBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    
    func checkMarkAnimation(){
        let animationView = AnimationView(name: "checkmark")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 1.5
        DispatchQueue.main.async {
            self.view.addSubview(animationView)
            animationView.play()
        }
        
    }
    
    func setUpLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServise(){
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAuthorization()
        }else{
            present(self.alertService.alert(mainTitle: "No Service", descText: "Please check your connection", buttonTitle:"KO", isGood: false, needButton: true), animated: true) {
            }
        }
    }
    
    @IBAction func screanTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
    }
    
    @objc func viewTapped(){
        userInfoView.isHidden = true
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTrackingUserLoactiong()
            break
        case .denied:
            // change massage to how to instruct the user to turn on the
            //alert(message: "The App is not authorized, Please authorized to continue", title: "Denied")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //alert(message: "The App is not authorized, Please authorized to continue", title: "Restricted")
            break
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    func addSearchBarToMapView(){
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        //MARK: Search Bar.
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for Customer Address"
        
        for s in searchBar.subviews[0].subviews {
            if s is UITextField {
                s.layer.borderColor = UIColor.blue.cgColor
                s.layer.cornerRadius = 10
                s.layer.shadowColor = UIColor.black.cgColor
                s.layer.shadowOpacity = 0.2
                s.layer.shadowOffset = CGSize(width: 0, height: 2)
            }
        }
        
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    func startTrackingUserLoactiong() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    ////////Change Buttons Apperiance
    func uiTipButton(button: UIButton) {
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 15
    }
    
    func uiCheapButton(button: UIButton){
        button.setTitleColor(UIColor.blue, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.blue.cgColor
    }
    
    ///////Change Location Container Apperiance
    func uiContainerDesign(){
        uiContainer.layer.masksToBounds = false
        uiContainer.layer.shadowColor = UIColor.black.cgColor
        uiContainer.layer.shadowOpacity = 0.1
        uiContainer.layer.shadowOffset = CGSize(width: -1, height: 1)
        uiContainer.layer.shadowRadius = 5
        uiContainer.layer.cornerRadius = 30.0
    }
    
    ///////Change NavigationBar Apperiance
    func navegationBarDesign(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.blue
    }
    
    
    /////////Delete: alert function
    func alert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    /////////tips alerts function
    func tippAlert(title: String, isTipped: Bool, newCustomer: CustomerItem){
        
        var cheapOrTipp = String()
        if isTipped{
            cheapOrTipp = "Customer Tipped"
        }else{
            cheapOrTipp = "Customer Cheapped"
            
        }
        let alertController = alertService.cheapOrTippAlert(mainTitle: cheapOrTipp, descText: "\(newCustomer.streetName + " " + newCustomer.houseNumber)", isTipped: isTipped)
        alertController.delegate = self
        present(alertController, animated: true)
        
        if newCustomer.streetName == ""{
            present(self.alertService.alert(mainTitle: "Street Name missing", descText: "Please make sure you have avalid address", buttonTitle:"KO", isGood: false, needButton: true), animated: true)
        } else if newCustomer.houseNumber == ""{
            present(self.alertService.alert(mainTitle: "House Number missing", descText: "Please make sure you havea valid address", buttonTitle:"KO", isGood: false, needButton: true), animated: true)
        } else if newCustomer.city == ""{
            present(self.alertService.alert(mainTitle: "City Name missing", descText: "Please make sure you have avalid address", buttonTitle:"KO", isGood: false, needButton: true), animated: true)
        }
        
    }
    
    //MARK:Animations Funcs
    func loginAnimation() {
        animationView = AnimationView(name: "loadingAnimation")
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height:  150)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        myView.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        myView.frame = self.view.frame
        animationView.animationSpeed = 1.5
        animationView.loopMode = .loop
        view.addSubview(myView)
        view.addSubview(animationView)
        self.animationView.play()
    }
    
    func checkAnimation() {
        animationView = AnimationView(name: "checkmark")
        animationView.frame = CGRect(x: 0, y: 0, width: 150, height:  150)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = 3.0
        myView.frame = self.view.frame
        view.addSubview(myView)
        view.addSubview(animationView)
        animationView.play { (finish) in
            self.animationView.stop()
            self.animationView.isHidden = true
            self.myView.isHidden = true
        }
    }
    
    func stopAnimation(){
        self.animationView.stop()
        self.animationView.isHidden = true
        self.myView.isHidden = true
    }
    
}

//MARK:Extantions
extension MapViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard let previousLocation = self.previousLocation else {return}
        guard center.distance(from: previousLocation) > 50 else {return}
        self.previousLocation = center
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                print(error as Any)
                return
            }
            
            guard let placemarks = placemarks?.first else {return}
            
            let streetName = placemarks.thoroughfare ?? ""
            let houseNumber = placemarks.subThoroughfare ?? ""
            let city = placemarks.subLocality ?? ""
            
            self.centerLocationAddress.streetName = streetName
            self.centerLocationAddress.houseNumber = houseNumber
            self.centerLocationAddress.city = city
            
            self.searchedCustomerAddress.streetName = streetName
            self.searchedCustomerAddress.houseNumber = houseNumber
            self.searchedCustomerAddress.city = city
            
            DispatchQueue.main.async {
                self.locationInfo.text = "\(streetName) \(houseNumber) \(city)"
            }
        }
    }
    
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKMarkerAnnotationView()
        guard let annotation = annotation as? Annotaition else {return nil}
        var identifier = ""
        var color = UIColor.red
        switch annotation.annotationType! {
        case .cheap:
            identifier = "black"
            color = .black
        case .tips:
            identifier = "grern"
            color = .green
        }
        
        if let dequedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView.markerTintColor = color
        annotationView.glyphTintColor = .yellow
        annotationView.clusteringIdentifier = identifier
        return annotationView
    }
    
}



extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark:MKPlacemark){
        if let streetName = placemark.thoroughfare, let houseNumber = placemark.subThoroughfare, let city = placemark.locality{
            searchedCustomerAddress.streetName = streetName
            searchedCustomerAddress.houseNumber = houseNumber
            searchedCustomerAddress.city = city
        }
        
        // cache the pin
        selectedPin = placemark
        
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        var doors = "Door Number: "
        var doorArray = [String]()
        let annotation =  Annotaition(coordinate: placemark.coordinate)
        annotation.coordinate = placemark.coordinate
        customerLocation = placemark.coordinate
        annotation.annotationType = .tips
        
        //Check if customer is in the list
        if customerList.count != 0 {
            for customer in customerList{
                if (customer == searchedCustomerAddress && customer.customerIsCheap == true){
                    annotation.annotationType = .cheap
                    doorArray.append("\(customer.doorNumber)")
                }
            }
        }
        //Add Annotation
        mapView.addAnnotation(annotation)
        if let street = placemark.thoroughfare,
            let houseNumber = placemark.subThoroughfare {
            annotation.title = "\(street) \(houseNumber)"
            
            if doorArray.count != 0{
                if doorArray.count > 1 {
                    doors = "Doors Number: "
                }
                annotation.subtitle = "\(doors) \(doorArray.joined(separator: ","))"
            }
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    
}
