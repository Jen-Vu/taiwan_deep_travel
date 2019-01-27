//
//  SecondViewController.swift
//  CoreMLDemo
//
//  Created by 李奇 on 2018/10/12.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit

var myIndex = 0
class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var passString2 = ""
    
    var myString = String()
    var img1 = ""
    var txt1 = ""
    var no1 = ""
    var img2 = ""
    var txt2 = ""
    var no2 = ""
    var img3 = ""
    var txt3 = ""
    var no3 = ""
    var img4 = ""
    var txt4 = ""
    var no4 = ""
    var img5 = ""
    var txt5 = ""
    var no5 = ""
    var imgAll = ["","","","",""]
    var txtAll = ["","","","",""]
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgAll.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.myImage.image = UIImage(named: imgAll[indexPath.row])
        cell.myLabel.text = txtAll[indexPath.row]
        
        return (cell)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("mystring為：")
        print(myString)
        var split2 = myString.components(separatedBy: ";")
        var n1 = split2[0].components(separatedBy: ",")
        var n2 = split2[1].components(separatedBy: ",")
        var n3 = split2[2].components(separatedBy: ",")
        var n4 = split2[3].components(separatedBy: ",")
        var n5 = split2[4].components(separatedBy: ",")
        img1 = n1[0]
        txt1 = n1[1]
        no1 = n1[2]
        img2 = n2[0]
        txt2 = n2[1]
        no2 = n2[2]
        img3 = n3[0]
        txt3 = n3[1]
        no3 = n3[2]
        img4 = n4[0]
        txt4 = n4[1]
        no4 = n4[2]
        img5 = n5[0]
        txt5 = n5[1]
        no5 = n5[2]
        imgAll[0] = img1
        imgAll[1] = img2
        imgAll[2] = img3
        imgAll[3] = img4
        imgAll[4] = img5
        txtAll[0] = txt1
        txtAll[1] = txt2
        txtAll[2] = txt3
        txtAll[3] = txt4
        txtAll[4] = txt5
        
        passString2 = no1 + "," + no2 + "," + no3 + "," + no4 + "," + no5
        print("passString2")
        print(passString2)
        
        //tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        performSegue(withIdentifier: "segue2", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if passString2 != ""{
            let newController = segue.destination as! NewViewController
            newController.myString2 = passString2
        }
    }

}
