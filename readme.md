## ItemManagementを継承するときの注意
ItemManagementクラスのitem_menuメソッド '3:メニューにもどる' の
menuメソッドはクラス内にないので、継承するクラス内に作る必要があります。

例
~~~ruby
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
~~~