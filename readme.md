## ItemManagementをincludeするときの注意

### メソッドについての注意
ItemManagementモジュールのitem_menuメソッド '3:メニューにもどる' の
menuメソッドはクラス内にないので、継承するクラス内に作る必要があります。

例
~~~ruby
class VendingMachineInterface < VendingMachineModel
#省略
  def menu
    puts "合計金額：#{@slot_money}"
    puts "0:コイン投入\n1:商品選択\n2:払い戻し\n3:商品管理画面"
    choice = gets.chomp.to_i
    case choice
    when 0
      before_throw_money
    when 1
      select_item
    when 2
      return_money
    when 3
      item_menu
    else
      puts "適切な数字を入れてください"
      menu
    end
  end
end
~~~

### インスタンス変数についての注意()
@itemsには{price:#,name:'#',quantity:#}の情報を追加してください
~~~ruby
class VendingMachineModel
  include ItemManagement
  def initialize
    @items = []
    @items << {price:120,name:'cola',quantity:5}
    @items << {price:100,name:'water',quantity:5}
    @items << {price:200,name:'redbull',quantity:5}
  end
#省略
end
~~~
