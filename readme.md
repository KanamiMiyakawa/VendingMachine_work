統合案

### 全体の構造、構造に関する注意点
- 一度インスタンスを作成すると、そのまま自動的に購入フローが進行する
VendingMachineInterfaceクラスのmenuメソッドでループし、そこから各メソッドに分岐
menuメソッド内のreturnでフローが終了する
- module ItemManagement : 商品管理に関する使いまわしの効くメソッド
- class VendingMachineModel : インスタンスとして実際の数値の加工、保存
- class VendingMachineInterface : Model内の各メソッドをつなぐインターフェイス


### こだわったポイント
- module ItemManagementを他の自動販売機にも使えるように設計
- スムーズでなるべく無駄のないメソッド間の遷移(Interface)
- 自動化しつつ、操作していて現在フローのどこにいるか分かりやすい構造を作る

### この辺はどうすればいいか？
- このコードの中に正規表現を使ったほうがよい箇所はあるか
- 冗長な箇所があるか、どこが特に読みにくいか
- 今のItemManagementはmoduleとして使える形でない気がする、本来のmoduleにするにはどう改善すればいいか？
以下問題点
  - ItemManagement内に、下位クラスで定義しなければならない変数がある
  - アイテム管理以外に、Interface的な役割も担って、フローの一部を規定してしまっている
  - initializeでパスや在庫の初期設定をしているが、ここでしてしまっていいのか？
  - VendingMachineInterfaceもmoduleにして、Modelと併せて３つを継承する実行クラスを作ってもよさそう