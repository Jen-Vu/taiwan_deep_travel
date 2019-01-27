//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by Sai Kambampati on 14/6/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var passString = ""
    
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var classifier: UILabel!
    
    @IBAction func startRecommend(_ sender: Any) {
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if passString != ""{
            let secondController = segue.destination as! SecondViewController
            secondController.myString = passString
        }
    }
    
    var model: MobileNet_place20s!
    
    override func viewWillAppear(_ animated: Bool) {
        model = MobileNet_place20s()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func camera(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //修正版餘弦相似公式
    func cosine_similarity(v1:[Double],v2:[Double])-> Double{
        var sumxx = 0.0
        var sumxy = 0.0
        var sumyy = 0.0
        var totalx = 0.0
        var totaly = 0.0
        
        for i in 0..<v1.count{
            totalx += v1[i]
            totaly += v2[i]
        }
        
        let meanx = totalx/Double(v1.count)
        let meany = totaly/Double(v2.count)
        
        for i in 0..<v1.count{
            let x = v1[i]
            let y = v2[i]
            sumxx += ((x-meanx)*(x-meanx))
            sumyy += ((y-meany)*(y-meany))
            sumxy += ((x-meanx)*(y-meany))
        }
        
        return sumxy/sqrt(sumxx*sumyy)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        //classifier.text = "Analyzing Image..."
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        imageView.image = newImage
        
        guard let prediction = try? model.prediction(image: pixelBuffer!) else {
            return
        }
        let probabilites = prediction.output // ['Male': 66.22, 'Female': 22.3212341]
        print(probabilites)
        let output = prediction.classLabel // 'Male
        print(output)

        var arrpro = Array(repeating: 0.0, count: 20)//存放隨機輸入圖片的機率(1,10)
        arrpro[0] = probabilites["遊樂園"]!
        arrpro[1] = probabilites["海灘"]!
        arrpro[2] = probabilites["植物園"]!
        arrpro[3] = probabilites["橋"]!
        arrpro[4] = probabilites["建築立面"]!
        arrpro[5] = probabilites["峽谷"]!
        arrpro[6] = probabilites["懸崖"]!
        arrpro[7] = probabilites["溪流"]!
        arrpro[8] = probabilites["森林_闊葉"]!
        arrpro[9] = probabilites["小島"]!
        arrpro[10] = probabilites["湖_天然"]!
        arrpro[11] = probabilites["草坪"]!
        arrpro[12] = probabilites["市場_戶外"]!
        arrpro[13] = probabilites["山"]!
        arrpro[14] = probabilites["山路"]!
        arrpro[15] = probabilites["博物館_戶外"]!
        arrpro[16] = probabilites["海洋"]!
        arrpro[17] = probabilites["碼頭"]!
        arrpro[18] = probabilites["摩天大樓"]!
        arrpro[19] = probabilites["廟_亞洲"]!
        
        //讀取.txt檔
        let filepath = Bundle.main.path(forResource: "20places_predict_895_str", ofType: "txt")
        
        var strss = ""
        do {
            // Get the contents
            let contents = try NSString(contentsOfFile: filepath!, encoding: String.Encoding.utf8.rawValue)
            //print(contents)
            strss = contents as String
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        //print(strss.count)
        let array1 = strss.components(separatedBy: ";")

        
        var array3: [[Double]] = [] //存放895張圖片的二維陣列(895,20)
        for _ in 0...894 {
            var subArray = [Double]()
            for _ in 0...19 {
                subArray.append(0.0)
            }
            array3.append(subArray)
        }
        
        for i in 0...894 {//895張圖片
            let array2 = array1[i].components(separatedBy: ",")
            for j in 0...19{//20個景點的機率
                array3[i][j] = Double(array2[j])!/10000000
            }
        }
        
        var similarity: [[Double]] = [] //用來存放餘弦相似度值的895個值和景點
        for _ in 0...894 {
            var subArray = [Double]()
            for _ in 0...1 {
                subArray.append(0)
            }
            similarity.append(subArray)
        }
        
        for i in 0...894 {
            similarity[i][0] = cosine_similarity(v1: arrpro, v2: array3[i])//#進行餘弦相似度比較
            similarity[i][1] = Double(i)//存放第幾個景點(int型態)
        }
        
       
        //895個景點名稱
        let placesNameTW = ["加路蘭" , " 目斗嶼" , " 吉貝嶼" , " 姑婆嶼" , " 險礁嶼" , " 觀音亭親水遊憩區" , " 菜園休閒漁業區" , " 風櫃洞" , " 嵵裡沙灘" , " 山水沙灘" , " 菓葉觀日樓" , " 北寮遊憩區" , " 東衛石雕公園" , " 中屯風力園區" , " 通梁古榕" , " 澎湖跨海大橋" , " 小門嶼" , " 二崁傳統聚落保存區" , " 內垵遊憩區" , " 漁翁島燈塔" , " 桶盤地質公園" , " 虎井嶼遊憩區" , " 網垵口沙灘" , " 花宅聚落(中社村)" , " 雙心石滬" , " 大獅風景區" , " 小台灣" , " 鯉灣遊憩區" , " 望夫石" , " 青螺溼地" , " 西嶼東臺軍事史蹟園區" , " 蛇頭山" , " 將軍澳嶼" , " 龍埕" , " 施公祠" , " 順承門" , " 大菓葉柱狀玄武岩" , " 重光里˙漳水神石碑" , " 案山里˙平安寶塔" , " 安宅里˙嶼仔尖塔" , " 鯨魚洞" , " 馬公港 漁人碼頭" , " 牛心山" , " 鳳凰山莊(賽斯村)" , " 富源保安宮" , " 瑞穗青蓮寺" , " 油菜花海" , " 池上牧野渡假村" , " 卑南溪泛舟" , " 鹿野崑慈堂" , " 鹿野觀光茶園" , " 猫囒山茶業改良場" , " 猫囒山步道" , " 雙龍瀑布" , " 龍鳳宮" , " 頭社盆地" , " 潭南村天主教堂" , " 銃櫃天寶堂" , " 慈恩塔" , " 集集綠色隧道" , " 梅荷園" , " 啟示玄機院" , " 草湳溼地" , " 紙教堂" , " 茅埔坑濕地公園" , " 耶穌堂" , " 青龍山步道" , " 蝴蝶園" , " 泥炭土活盆地" , " 武昌宮" , " 明潭電廠" , " 明潭水庫" , " 車埕木業展示館" , " 好茭情/吟詩綠曲茭白筍休閒體驗園區" , " 地母廟" , " 向山行政暨遊客中心" , " 玄奘寺" , " 玄光寺" , " 正德大佛" , " 水蛙頭步道" , " 木生昆蟲博物館" , " 月潭自行車道" , " 日月潭纜車" , " 文武廟" , " 大雁村澀水社區" , " 大竹湖步道" , " 土亭仔步道" , " 三聖宮" , " 九龍口" , " 見晶宮" , " 泰雅渡假村" , " 九龍口大平台" , " 國立暨南國際大學" , " 茶香步道" , " 八卦力部落" , " 寶藏寺" , " 環山部落" , " 武陵農場" , " 銅鏡山林步道" , " 靈霞洞" , " 峨眉湖環湖步道" , " 荔枝王" , " 谷關大道院" , " 楓之谷-1956秘密花園" , " 金剛寺" , " 加里山步道" , " 受天宮" , " 谷關街道" , " 古厝聚落" , " 萬佛庵" , " 八仙山森林遊樂區" , " 二水自行車道" , " 蓬萊溪自然生態園區" , " 梨山賓館" , " 梨山賓館生態環保步道" , " 望月亭" , " 碧山岩" , " 谷關七雄" , " 猿山步道" , " 天池" , " 捎來步道" , " 茶二指故事館" , " 橫屏背生態賞魚步道" , " 水濂橋步道" , " 勸化堂" , " 福壽山農場" , " 山塘背登山步道" , " 德基水庫" , " 二水登廟步道" , " 虎山岩" , " 縣139線觀景道路" , " 向天湖" , " 水濂洞" , " 希利克步道siliq" , " 朴子溪口溼地(朴子溪出海口)" , " 白水湖" , " 魍港太聖宮" , " 將軍觀光漁港" , " 蚵寮漁港" , " 北門潟湖" , " 土城正統鹿耳門聖母廟" , " 台灣鹽博物館" , " 七股海產街" , " 成龍濕地" , " 雙春濱海遊憩區" , " 三寮灣東隆宮" , " 錢來也雜貨店" , " 夕遊鹽樂活村(原:台灣鹽樂活村)" , " 東石先天宮" , " 南布袋濕地" , " 青山漁港" , " 北門嶼基督教會" , " 外傘頂洲沙灘" , " 好蝦冏男社" , " 水晶教堂" , " 田尾公路花園" , " 永靖花卉" , " 八卦山大佛風景區" , " 百果山風景區" , " 田中森林公園" , " 西螺大橋觀夕照" , " 綠色環境學習營地" , " 孔子廟" , " 道東書院" , " 大丘園休閒農場" , " 稻香休閒農場" , " 埔茂花卉" , " 梅庄花卉生產休憩園區" , " 路葡萄酒莊-路葡萄隧道" , " 伸港海灘牛車樂" , " 王功漁港" , " 福寶溼地賞鳥" , " 鷹揚八卦" , " 聖王廟" , " 元清觀" , " 益源古厝" , " 鹿港龍山寺" , " 慶安宮" , " 芬園寶藏寺" , " 定光佛廟" , " 南瑤宮" , " 節孝祠" , " 關帝廟" , " 永靖餘三館" , " 開化寺" , " 懷忠祠" , " 鹿港城隍廟" , " 鹿港天后宮" , " 鹿港文武廟" , " 鹿港地藏王廟" , " 興安宮" , " 花壇虎山巖" , " 鹿港金門館" , " 鹿港隘門" , " 鹿港鳳山寺" , " 鹿港南靖宮" , " 鹿港三山國王廟" , " 彰化市武德殿" , " 員林興賢書院" , " 員林神社遺跡" , " 羅厝天主堂" , " 意和行" , " 劉宅月眉池" , " 不老泉" , " 溪湖庄役場" , " 花壇中庄李宅正身" , " 友鹿軒" , " 員林市江九合濟陽堂" , " 社頭斗山祠" , " 白馬峯普天宮" , " 半邊井" , " 楊橋公園/護安宮" , " 彰化藝術館" , " 鹿港民俗文物館" , " 鹿港老街" , " 歡喜生態園" , " 北斗奠安宮" , " 鹿港丁家大宅" , " 北頭土地祠" , " 新祖宮" , " 挑水古道賞桐花" , " 長青登山步道" , " 二八彎古道" , " 鹿港第一市場" , " 永安宮" , " 集英宮" , " 威靈廟" , " 忠義廟" , " 慈靈宮" , " 官林宮" , " 社頭清水岩寺" , " 大佛環山步道(懷古人文遊憩之旅)" , " 賞鷹步道(轆山坑步道)" , " 桃源里森林步道群(休閒賞鷹之旅)" , " 虎山岩步道(人文遊憩之旅)" , " 四面佛．油桐花步道(禮佛賞花之旅)" , " 碧山岩古道(探古賞景之旅)" , " 飛鷹穴步道(健行賞景之旅)" , " 百果山登山步道(百坎步道)(健行賞景之旅)" , " 十八彎古道(原始探古之旅)" , " 觀音山五峰步道．中央嶺步道(原始探古之旅)" , " 猴探井登山步道(探古賞景之旅)" , " 橫山步道(探古賞景之旅)" , " 麒麟山步道(探古賞景之旅)" , " 田中森林公園．赤水崎步道(登山懷舊之旅)" , " 茶香步道(健行品茗之旅)" , " 登廟步道．坑內坑步道(健行生態之旅)" , " 許木農村文物館" , " 西門福德祠" , " 清水岩遊憩區" , " 福海宮" , " 咸安宮" , " 西港、公館沙崙鷺鷥區" , " 張玉姑廟" , " 怡心園" , " 福安宮" , " 芬園花卉生產休憩園區" , " 錫安祠樹包廟" , " 過溝村葡萄王老樹" , " 就是愛荔枝樂園" , " 林先生廟" , " 白馬休閒農園" , " 彰化溪州公園" , " 顏氏牧場" , " 彰化縣立美術館" , " 萬景藝苑" , " 八卦山天空步道" , " 員林衡文宮" , " 二八水水公園" , " 中寮鄉龍鳳瀑布空中步道" , " 北港朝天宮" , " 褒忠馬鳴山鎮安宮" , " 太平老街" , " 西螺大橋" , " 古坑綠色隧道" , " 古坑情人橋" , " 虎尾鐵橋" , " 拱範宮" , " 雅聞峇里海岸" , " 草嶺-幽情谷" , " 二崙新虎溪" , " 二崙濁水夕照" , " 二崙運動公園" , " 湖口溼地" , " 媽祖景觀公園" , " 蕃薯厝順天宮" , " 綠色一線天自行車道" , " 武德宮(五路財神廟)" , " 湖山岩大佛寺／佛教藝術園區" , " 張廖宗祠(崇遠堂)" , " 振興宮" , " 圓明禪寺" , " 天聖宮" , " 劍湖山世界" , " 林內公園" , " 白馬山菩提講堂" , " 福天宮" , " 樹仔腳天主堂" , " 同心家園" , " 捷發乾記茶莊(延平老街文化館)" , " 縣定古蹟 西螺廣福宮西螺媽老大媽廟" , " 福興宮" , " 振文書院(文祠廟)" , " 三條崙漁港" , " 台西漁港" , " 荷苞山地母廟" , " 義民廟" , " 北港觀光大橋" , " 斗南順安宮" , " 金湖萬善爺廟" , " 三山國王廟" , " 日落蚵田" , " 雲嶺之丘" , " 椬梧滯洪池" , " 龍過脈森林步道" , " 湖山水庫" , " 北港女兒橋" , " 五元兩角" , " 萡子寮漁港" , " 西螺延平老街(西螺東市場)" , " 蘿莎玫瑰山莊" , " 貝克翰農場" , " 草嶺地質生態國小" , " 媽祖廟(慈鳳宮)" , " 崇蘭蕭家古厝" , " 屏東夜市" , " 瑞光夜市" , " 玉皇宮" , " 龔家古厝" , " 麟洛自行車道" , " 清波蘭園" , " 穎達生態休閒農場" , " 安巒山莊休閒農場" , " 萬金綠色隧道" , " 萬巒豬腳街" , " 五溝村劉氏宗祠" , " 潮州市民農園" , " 八大森林遊樂園" , " 東港東隆宮" , " 朝隆宮" , " 鎮海宮" , " 長老教會" , " 漁獲拍賣市場" , " 福灣養生休閒農場(福灣莊園)" , " 六堆忠義祠" , " 東望樓" , " 內埔天后宮" , " 昌黎祠" , " 霧臺基督長老教會" , " 霧臺石板聚落" , " 怡然居螢火蟲生態休閒農場" , " 花瓶岩" , " 沙瑪基渡假區" , " 肚仔坪" , " 杉福漁港" , " 山豬溝風景區" , " 蛤板灣風景區" , " 落日亭" , " 海子口" , " 厚石群礁" , " 百年榕樹" , " 秘密沙灘" , " 龍蝦洞" , " 白沙觀光港" , " 竹林生態溼地公園" , " 里龍山步道" , " 福安宮" , " 保力林場" , " 海口沙漠" , " 後灣" , " 墾丁國家森林遊樂區" , " 小灣海水浴場" , " 墾丁大街" , " 青蛙石" , " 砂島生態保護區" , " 香蕉灣生態保護區" , " 龍磐公園" , " 水蛙窟" , " 臺灣最南點意象標誌" , " 墾丁牧場" , " 龍鑾潭" , " 後壁湖" , " 貓鼻頭公園" , " 山海漁村" , " 萬里桐" , " 墾丁海水浴場(大灣)" , " 紅柴坑" , " 關山夕照" , " 恆春老街" , " 內文部落" , " 壽峠林道" , " 東源森林遊樂區" , " 佳德谷原住民植物生活教育園區" , " 牡丹水庫" , " 旭海草原" , " 滿州里德花海" , " 滿州里德" , " 門馬羅山" , " 港口情人橋" , " 南大武山" , " 北大武山" , " 阿郎壹古道" , " 都城隍廟" , " 北玄宮" , " 跨海大橋" , " 林投公園" , " 菓葉日出" , " 通樑古榕" , " 東臺古堡" , " 施公祠及萬軍井" , " 蛇頭山遊憩區" , " 菊島之星(漁人碼頭)" , " 蔡廷蘭進士第" , " 牛心山(牛心灣)" , " 赤崁親水公園" , " 二崁陳家古厝" , " 中央老街" , " 二崁草原" , " 西台餌砲(外垵餌砲)" , " 夢幻沙灘" , " 西嶼大義宮" , " 赤馬沙灘" , " 奎壁山地質公園(摩西分海)" , " 後灣沙灘" , " 赤崁仙人掌公園" , " 白坑沙灘" , " 青螺濕地" , " 彩繪油桶(漁人碼頭)" , " 馬公水仙宮(臺廈郊會館)" , " 澎湖孔廟(文石書院)" , " 西瀛虹橋" , " 雙湖園" , " 青灣玄武岩" , " 觀星公園" , " 興仁水庫" , " 溫王宮" , " 馬公東甲北極殿(啟明)" , " 媽宮城隍廟" , " 觀音亭" , " 景福祠" , " 馬公北甲北辰宮" , " 澎湖紫微宮" , " 祖師爺廟" , " 宸威殿" , " 菜園濕地" , " 七美島" , " 山水濕地公園" , " 白沙嶼" , " 西吉嶼" , " 東吉嶼" , " 東嶼坪" , " 雞善嶼" , " 鐵砧嶼" , " 外垵村、外垵漁港" , " 三石壁" , " 小池角石雕園區" , " 沙港古厝群" , " 鎮海洋樓" , " 瓦硐張百萬故居" , " 蘭潭風景區" , " 百年嘉義公園" , " 香湖公園" , " 黃石公有零售市場" , " 碧潭風景區" , " 三峽清水祖師廟" , " 龍洞灣海洋公園(龍洞灣)" , " 三峽老街" , " 林本源園邸" , " 板橋湳雅觀光夜市" , " 板橋後站商圈(府中商圈)" , " 板橋435藝文特區" , " 鹿角溪人工溼地" , " 炮子崙瀑布" , " 皇帝殿登山步道" , " 南雅奇岩(南雅奇石)" , " 平溪老街" , " 十分老街" , " 雙溪區自行車道" , " 保坪宮" , " 坪林老街" , " 淡水海關碼頭園區" , " 天上山系步道" , " 黃金瀑布" , " 牧師樓" , " 富士坪古道" , " 大棟山" , " 遠望坑親水公園" , " 大漢溪自行車道" , " 舊草嶺隧道" , " 蔡家洋樓" , " 猴硐貓橋" , " 靈鷲山無生道場" , " 無緣之墓登山步道(貂山古道)" , " 雲門劇場" , " 雞籠山登山步道" , " 大粗坑古道" , " 望古瀑布" , " 舊草嶺環狀自行車道" , " 淡蘭古道石碇段" , " 草嶺古道" , " 三貂嶺瀑布步道" , " 嶺腳寮登山步道" , " 鴨鴨地景藝術公園" , " 柑園生態河濱公園" , " 太極嶺" , " 北勢溪自行車道" , " 淡水漁人舞台" , " 野柳登山步道" , " 楓樹湖" , " 陀彌天 紫竹林寺" , " 玉皇宮(天公廟)" , " 佛光山" , " 臺灣天壇" , " 九番埤濕地公園" , " 岡山公園" , " 壽天宮" , " 高雄市立圖書總館" , " 高雄展覽館" , " 光榮碼頭" , " 高雄關帝廟(武廟)" , " 多納高吊橋" , " 得樂日嘎橋" , " 多納部落" , " 舊茂林遺跡" , " 白雲寺" , " 桃源梅山" , " 紅樹林茄苳溪保護區" , " 哨船頭遊艇碼頭" , " 高雄港" , " 忠烈祠" , " 鼓山公園" , " 地景橋" , " 旗后燈塔" , " 旗後教會" , " 旗津天后宮" , " 鳳凰山" , " 鳳山天公廟" , " 興達港" , " 澄清湖風景區" , " 舊鐵橋濕地教育園區" , " 大崗山風景區" , " 大寮包公廟" , " 五甲公園" , " 八五大樓" , " 內門紫竹寺" , " 大東公園" , " 鳳山龍山寺" , " 旗山老街" , " 半屏山自然公園" , " 田寮月世界" , " 光之塔" , " 西子灣" , " 木柵吊橋" , " 覆鼎金保安宮" , " 鳳儀書院" , " 清水巖風景區" , " 孔廟" , " 十八羅漢山風景區" , " 妙崇寺" , " 寶來妙通寺" , " 壽山情人觀景臺" , " 彌陀海濱遊樂區" , " 旗山天后宮" , " 開漳聖王廟" , " 雙慈亭" , " 佛光山佛陀紀念館" , " 順賢宮" , " 紫蝶幽谷" , " 茂林谷" , " 茂林國家風景區" , " 香蕉碼頭" , " 美濃湖" , " 張媽媽桑椹休閒農場" , " 觀音山風景區" , " 阿公店水庫" , " 啟明堂" , " 大愛園區" , " 黃蝶翠谷" , " 紅毛港文化園區" , " 新威森林公園" , " 高雄都會公園" , " 義大世界" , " 高屏溪斜張橋" , " 凹仔底森林公園" , " 世紀大峽谷" , " 竹滬明寧靖王廟-華山殿" , " 旗津風車公園" , " 鳥松濕地" , " 大坪頂熱帶植物園" , " 蓮池潭風景區" , " 衛武營都會公園" , " 玫瑰聖母聖殿主教座堂" , " 諦願寺" , " 茂林三大名山-龍頭山、蛇頭山與龜形山" , " 呂家古厝" , " 鳳邑舊城城隍廟" , " 永齡杉林有機農業園區" , " 三鳳宮" , " 慈濟宮" , " 愛河" , " 西臨港線自行車道" , " 高屏溪地水護岸自行車道" , " 鳳山城隍廟" , " 旗津海水浴場" , " 旗后砲台" , " 二仁溪親水公園" , " 法鼓山紫雲寺" , " 永安發" , " 六龜大佛" , " 寶來花賞溫泉公園" , " 崗山之眼" , " 聚點美式餐廳" , " 永浴愛河" , " 路竹天后宮" , " 新威景觀大橋" , " 杉林大橋" , " 淨園休閒農場" , " 永安宮" , " 天文宮" , " 玉竹商圈" , " 國立傳統藝術中心" , " 國立國父紀念館" , " 國立中正紀念堂(國立中正紀念堂管理處)" , " 國立歷史博物館" , " 國立臺灣美術館" , " 台灣工藝文化園區 (國立臺灣工藝研究發展中心)" , " 藝之森-九九峰生態藝術園區  (國立臺灣工藝研究發展中心)" , " 苗栗工藝園區 (國立臺灣工藝研究發展中心)" , " 國立臺灣博物館" , " 國立臺灣史前文化博物館" , " 國立臺灣文學館" , " 國家人權博物館籌備處景美人權文化園區" , " 國家人權博物館籌備處綠島人權文化園區" , " 國立彰化生活美學館" , " 國立臺南生活美學館" , " 國立臺東生活美學館102" , " 台中文化創意產業園區 (文化資產局)" , " 有河book" , " 虎尾厝沙龍" , " 鶵鳥藝文空間" , " 新北投溫泉區" , " 大稻埕碼頭" , " 士林官邸" , " 國立故宮博物院" , " 北投圖書館" , " 陽明山溫泉區" , " 關渡、金色水岸、八里左岸自行車道" , " 大安森林公園" , " 地熱谷" , " 南港山系-象山親山步道" , " 艋舺龍山寺" , " 行天宮" , " 梅庭" , " 中正紀念堂" , " 北投溫泉博物館" , " 華山1914文化創意產業園區" , " 北投公園" , " 台北霞海城隍廟" , " 河濱自行車道" , " 台北101" , " 陽明山國家公園" , " 臺北市立動物園" , " 碧湖公園" , " 基隆河左、右岸親水" , " 大湖公園" , " 臺北忠烈祠" , " 關渡碼頭-甘豆門" , " 社子島環島與二重疏洪道自行車道" , " 七星山系-天母古道親山步道" , " 臺北市立美術館" , " 行天宮北投分宮-忠義廟" , " 國立歷史博物館" , " 冷水坑溫泉區" , " 西門紅樓" , " 松山慈祐宮" , " 關渡宮" , " 內溝溪景觀生態步道" , " 二二八和平公園" , " 指南宮" , " 台北當代藝術館" , " 北投文物館" , " 松山文創園區" , " 大龍峒保安宮" , " 雙溪生活水岸" , " 陽明山中山樓" , " 臺北市鄉土教育中心(剝皮寮歷史街區)" , " 自來水博物館" , " 華中河濱公園" , " 關渡自然公園" , " 碧山巖開漳聖王廟" , " 馬場町紀念公園" , " 芝山文化生態綠園(芝山岩展示館)" , " 大佳碼頭-圓山仔" , " 總統府" , " 大佳河濱公園" , " 南港山系-虎山親山步道" , " 紫藤廬" , " 大屯山系-軍艦岩親山步道" , " 二格山系-仙跡岩親山步道" , " 臺北市孔廟" , " 社子島島頭公園" , " 二格山系-指南宮貓空親山步道" , " 台北故事館" , " 國立臺灣博物館" , " 彩虹橋" , " 五指山系-劍潭山親山步道" , " 北投普濟寺" , " 天后宮" , " 聖家堂" , " 白石湖吊橋" , " 大屯山系-中正山親山步道" , " 艋舺清水巖" , " 陽明山光復樓" , " 小南門" , " 欽差行臺" , " 南港山系-更寮古道親山步道" , " 艋舺青山宮" , " 新生公園" , " 大屯山系-關渡親山步道" , " 七星山系-坪頂古圳親山步道" , " 芝山巖惠濟宮" , " 天恩宮" , " 美堤碼頭" , " 劍潭古寺" , " 二格山系-指南茶路親山步道" , " 清真寺" , " 少帥禪園" , " 士林官邸公園" , " 景美集應廟" , " 南港山系-麗山橋口親山步道" , " 鳥籠外的花園" , " 文昌祠" , " 五指山系-大崙頭尾山親山步道" , " 大屯山系-忠義山親山步道" , " 五指山系-忠勇山、鯉魚山親山步道" , " 圓山飯店" , " 慈諴宮" , " 五指山系-金面山親山步道" , " 內雙溪自然公園" , " 五指山系-白鷺鷥山、康樂山、明舉山親山步道" , " 陽明山夜景" , " 擎天崗草原" , " 艋舺公園" , " 碧湖步道" , " 花博公園" , " 臺北市立兒童新樂園" , " 紀州庵文學森林" , " 和平青草園(原萬華402號公園)" , " 和平青草園(原萬華402號公園)" , " 和平青草園(原萬華402號公園)" , " 臺北小巨蛋" , " 樟山寺" , " 松山慈惠堂" , " 華江雁鴨自然公園" , " 南港公園" , " 迪化運動公園跨堤景觀平臺" , " 興隆公園" , " 仙岩公園" , " 三腳渡擺渡口" , " 南港茶葉製造示範場(台北找茶園)" , " 國立臺灣藝術教育館" , " 台灣基督長老教會大稻埕教會" , " 青年公園" , " 貓空纜車" , " 美麗華百樂園" , " 中山基督長老教會" , " 復興三路櫻花隧道" , " 賞櫻環湖步道" , " 文山教會" , " 文昌宮" , " 西門町徒步區" , " 士林神農宮" , " 財團法人台北市臺灣省城隍廟" , " 郊山友台" , " 山水綠生態公園" , " 松山奉天宮" , " 龍安坡黃宅濂讓居" , " 艋舺地藏庵" , " 陳德星堂" , " 內湖復育園區" , " 平等里櫻花" , " 芝山公園" , " 萬慶巖清水祖師廟" , " 竹子湖海芋季" , " 景福宮" , " 榮星花園公園" , " 農禪寺" , " 大直植福宮" , " 學海書院（今高氏宗祠）" , " 臺北當代工藝設計分館" , " 大稻埕慈聖宮" , " 福州山公園" , " 至德園公園" , " 國立暨南國際大學" , " 中台禪寺" , " 前山第一城石碣" , " 橋聳雲天(國道六號國姓交流道)" , " 武昌宮" , " 碧湖（萬大水庫）" , " 武嶺" , " 坑內坑森林步道" , " 竹山連興宮" , " 中台世界博物館" , " 日月潭涵碧步道" , " 日月潭水蛙頭步道" , " 烏松崙觀光梅園" , " 日月潭後尖山步道" , " 日月潭青龍山步道" , " 水社大山步道" , " 永興大樟樹" , " 南投野溪溫泉-精英溫泉" , " 龍鳳瀑布" , " 日月潭大竹湖步道" , " 名間新街冷泉濕地" , " 日月潭伊達邵親水步道" , " 父不知子斷崖" , " 曲冰遺址" , " 八通關古道" , " 清境高空觀景步道" , " 紫南宮" , " 松柏嶺受天宮" , " 合歡山國家森林遊樂區" , " 桶頭風景區" , " 忘憂森林" , " 鶴山步道" , " 中寮鄉龍鳳瀑布空中步道" , " 毓繡美術館" , " 欣隆休閒農場" , " 天空之橋-猴探井風景區" , " 軟鞍八卦茶園(大鞍竹海風景區)" , " 觀音瀑布" , " LaLu島(拉魯)" , " 雙十吊橋" , " 風櫃斗梅園" , " 上安觀光果園" , " 蟬說雅築" , " 登瀛書院" , " 福龜草莓園" , " 茶葉改良場-魚池分場" , " 藍田書院" , " 韭菜溪湖(偃塞湖)" , " 龍興吊橋" , " 豐丘葡萄觀光果園" , " 青竹竹文化園區" , " 日月潭年梯步道" , " 明湖水庫（明潭）" , " 明新書院" , " 清境農場" , " 奧萬大國家森林遊樂區" , " 集集大山" , " 杉林溪森林生態渡假園區" , " 集集綠色隧道" , " 鯉魚潭" , " 大眾爺祠（大樟樹）" , " 日月潭" , " 糯米橋" , " 雙龍瀑布" , " 梅峰–台大山地農場" , " 九族文化村" , " 泰雅渡假村" , " 台大下坪自然教育園區" , " 草坪頭玉山茶園" , " 草屯九九峰健行步道" , " 文武廟" , " 竹山天梯(梯子吊橋)" , " 東埔吊橋" , " 彩虹瀑布" , " 林班道商圈" , " 集集瀑布(神仙洞)" , " 坪瀨琉璃光之橋健行園區" , " 瑞龍瀑布" , " 蘭潭音樂噴泉" , " 檜意森活村" , " 森林之歌" , " 北門驛" , " 蘭潭月影潭心" , " 射日塔" , " 行嘉吊橋" , " 嘉義市百年老樹-鳥榕王萬靈廟" , " 蘭潭風景區" , " 蘭潭後山公園" , " 百年嘉義公園" , " 嘉義樹木園" , " 嘉大植物園" , " 文化中心旁杉池" , " 文化路夜市" , " 嘉油鐵馬道" , " 世賢路自行車道" , " 嘉義仁武宮" , " 國定古蹟嘉義城隍廟" , " 九華山地藏庵" , " 嘉義神社手水舍" , " 彌陀寺" , " 蘇周連宗祠" , " 香湖公園" ]
        
        //similarity2全部改為similarity
        
        //尋找最相似的圖片
        var maxIndex = 0//放最大值的索引(0到10)
        var maxValue = -2.0//放最大值的值
        
        for i in 0...894{
            if similarity[i][0]>maxValue{
                maxValue = similarity[i][0]
                maxIndex = Int(similarity[i][1])//轉成int型態
            }
        }

        similarity[maxIndex][0] = -3.0//相似度歸-3.0
        
        print("最相似的圖片為：")
        print("NO：", maxIndex+1)
        print(placesNameTW[maxIndex])
        print("相似度：",maxValue)
        //print('介紹：', placesIntroductionTW[maxIndex])
        
        //let text1 = "最相似的圖片為："+"\n"+"NO：" + String(maxIndex+1)+"\n"+placesNameTW[maxIndex]+"\n"+"相似度："+String(maxValue)
        let text1 = "推薦景點首選："+"\n"+placesNameTW[maxIndex]
        let no1 = String(maxIndex)
        
        //顯示最相似的圖片
        var name2 = String(maxIndex+1)
        while(name2.count<8){
            name2 = "0" + name2
        }
        
        let imgtop1 = name2
        
        
        //尋找第二相似的圖片
        maxIndex = 0//放最大值的索引(0到10)
        maxValue = -2.0//放最大值的值
        
        for i in 0...894{
            if similarity[i][0]>maxValue{
                maxValue = similarity[i][0]
                maxIndex = Int(similarity[i][1])//轉成int型態
            }
        }
        
        similarity[maxIndex][0] = -3.0//相似度歸-3.0
        
        print("第二相似的圖片為：")
        print("NO：", maxIndex+1)
        print(placesNameTW[maxIndex])
        print("相似度：",maxValue)
        //print('介紹：', placesIntroductionTW[maxIndex])
        
        let text2 = "推薦景點次選："+"\n"+placesNameTW[maxIndex]
        let no2 = String(maxIndex)
        
        //顯示最相似的圖片
        name2 = String(maxIndex+1)
        while(name2.count<8){
            name2 = "0" + name2
        }
        
        let imgtop2 = name2
        
        //尋找第三相似的圖片
        maxIndex = 0//放最大值的索引(0到10)
        maxValue = -2.0//放最大值的值
        
        for i in 0...894{
            if similarity[i][0]>maxValue{
                maxValue = similarity[i][0]
                maxIndex = Int(similarity[i][1])//轉成int型態
            }
        }
        
        similarity[maxIndex][0] = -3.0//相似度歸-3.0
        
        print("第三相似的圖片為：")
        print("NO：", maxIndex+1)
        print(placesNameTW[maxIndex])
        print("相似度：",maxValue)
        //print('介紹：', placesIntroductionTW[maxIndex])
        
        //let text3 = "第三相似的圖片為："+"\n"+"NO：" + String(maxIndex+1)+"\n"+placesNameTW[maxIndex]+"\n"+"相似度："+String(maxValue)
        let text3 = "推薦景點還有："+"\n"+placesNameTW[maxIndex]
        let no3 = String(maxIndex)
        
        //顯示第三相似的圖片
        name2 = String(maxIndex+1)
        while(name2.count<8){
            name2 = "0" + name2
        }
        
        let imgtop3 = name2
        
        //尋找第四相似的圖片
        maxIndex = 0//放最大值的索引(0到10)
        maxValue = -2.0//放最大值的值
        
        for i in 0...894{
            if similarity[i][0]>maxValue{
                maxValue = similarity[i][0]
                maxIndex = Int(similarity[i][1])//轉成int型態
            }
        }
        
        similarity[maxIndex][0] = -3.0//相似度歸-3.0
        
        print("第四相似的圖片為：")
        print("NO：", maxIndex+1)
        print(placesNameTW[maxIndex])
        print("相似度：",maxValue)
        //print('介紹：', placesIntroductionTW[maxIndex])
        
        //let text4 = "第四相似的圖片為："+"\n"+"NO：" + String(maxIndex+1)+"\n"+placesNameTW[maxIndex]+"\n"+"相似度："+String(maxValue)
        let text4 = "推薦景點還有："+"\n"+placesNameTW[maxIndex]
        let no4 = String(maxIndex)
        
        //顯示第四相似的圖片
        name2 = String(maxIndex+1)
        while(name2.count<8){
            name2 = "0" + name2
        }
        
        let imgtop4 = name2
        
        
        //尋找第五相似的圖片
        maxIndex = 0//放最大值的索引(0到10)
        maxValue = -2.0//放最大值的值
        
        for i in 0...894{
            if similarity[i][0]>maxValue{
                maxValue = similarity[i][0]
                maxIndex = Int(similarity[i][1])//轉成int型態
            }
        }
        
        similarity[maxIndex][0] = -3.0//相似度歸-3.0
        
        print("第五相似的圖片為：")
        print("NO：", maxIndex+1)
        print(placesNameTW[maxIndex])
        print("相似度：",maxValue)
        //print('介紹：', placesIntroductionTW[maxIndex])
        
        //let text5 = "第五相似的圖片為："+"\n"+"NO：" + String(maxIndex+1)+"\n"+placesNameTW[maxIndex]+"\n"+"相似度："+String(maxValue)
        let text5 = "推薦景點還有："+"\n"+placesNameTW[maxIndex]
        let no5 = String(maxIndex)
        
        //顯示第五相似的圖片
        name2 = String(maxIndex+1)
        while(name2.count<8){
            name2 = "0" + name2
        }
        
        let imgtop5 = name2
        
        passString = imgtop1+","+text1+","+no1+";"+imgtop2+","+text2+","+no2+";"+imgtop3+","+text3+","+no3+";"+imgtop4+","+text4+","+no4+";"+imgtop5+","+text5+","+no5
        print("passString為：")
        print(passString)
        
        
    }
}
