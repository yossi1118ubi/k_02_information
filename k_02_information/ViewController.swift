//
//  ViewController.swift
//  k_02_information
//
//  Created by Daichi Yoshikawa on 2020/09/11.
//  Copyright © 2020 Daichi Yoshikawa. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, UITableViewDelegate{
    
    
    var json:[ItemJson]?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //nil対策をしている. ただ, このへんで?と!をなんとなく使うのをやめて,　しっかり使いたい
        if let table_count:Int = qittaList.count{
            print("&&&&&&&&&&&&&&カウントしてます: \(table_count)")
            
            return table_count
        }else{
        //リストの総数
        print("&&&&&&&&&&&&&&&&カウントできてない")
        return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行う, cellオブジェクト(1行)をい取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "inforCell", for: indexPath as IndexPath)
        
        //Cellの高さを設定
        tableView.rowHeight = 200
        print("##################")
        //cell.textLabel?.text = qittaList[indexPath.row].title
        
        //Titleのラベルオブジェクトを作る
        let labelTitle = cell.viewWithTag(1) as! UILabel
        //Titleのラベルに表示する文字列を設定
        labelTitle.text = (qittaList[indexPath.row].title)
        
        //Titleのラベルオブジェクトを作る
        let labelDate = cell.viewWithTag(2) as! UILabel
        //Titleのラベルに表示する文字列を設定
        labelDate.text = (qittaList[indexPath.row].date)

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ){
        //ハイライト削除
        tableView.deselectRow(at: indexPath, animated: true)
        //SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: qittaList[indexPath.row].url)
        
        //delegateの通知先を自分自身
        safariViewController.delegate = self
        
        //SafariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
        
    }
    
    //SafariViewが閉じられた時に呼ばれるdelegateメソッド
      func safariViewControllerDidFinish(_ controller: SFSafariViewController){
          //SafariViewを閉じる
          dismiss(animated: true, completion: nil)
      }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //サーチバーのデリゲイトを自分自身に設定
        searchText.delegate = self
        //入力のヒントtなる, プレースホルダーを設定
        searchText.placeholder = "記事を検索"
        
        //Table ViewのdataSourceを設定
        tableView.dataSource = self
        
        //Table Of ViewのDelegateを設定
        tableView.delegate = self
    }
    
    @IBOutlet weak var searchText: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var qittaList: [(title: String, date: String, url: URL) ] = []
    var listCount: Int = 0
    
    //検索ボタンをタップした時に実行されるメソッド
    //これはあらかじめ決められているメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる(iOSは勝手に閉じてくれない)
        view.endEditing(true)
        
        //if letは searchWordにテキストが入っていれば実行される
        if let searchWord = searchBar.text{
            
            //デバックエリアに出力
            print(searchWord)
            
            searchQitta(keyword: searchWord)
        }
        
    }
    
    //Qittaの記事を検索
    func searchQitta(keyword: String){
        //検索キーワードをURLエンコードする
        //全角文字がある場合に半角文字に直す
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
      
        guard let req_url = URL(string: "https://qiita.com/api/v2/items?page=1&per_page=10&query=title:\(keyword_encode)") else {
            return
        }
        
        print(req_url)
        
        //リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        
        //データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        //リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {(data, response, error) in
            //セッションを終了
            session.finishTasksAndInvalidate()
            
            //do try catch エラーハンドリング
            do{
                //JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                
                
                //受け取ったJSONデータをパース(解析)して格納
                let json:[ItemJson] = try decoder.decode([ItemJson].self, from: data!)
                
                print(json)
                
                self.listCount = json.count - 1
                self.qittaList.removeAll()
                
                for i in 0...self.listCount {
                    if let title = json[i].title, let date = json[i].created_at, let url = json[i].url{
                        let qitta_taple = (title, date, url)
                        
                        self.qittaList.append(qitta_taple)
                    }
                
                    
                }
                
                self.tableView.reloadData()
                
            }catch{
                //エラー処理
                print("エラーが発生しました")
            }
        })
        
        task.resume()

    }
    
    struct ItemJson: Codable{
        //タイトルを格納
        let title:String?
        //投稿日
        let created_at: String?
        
        //掲載URL
        let url:URL?
        
        //中身
//        let body: String?
    }
    
        
    
}

