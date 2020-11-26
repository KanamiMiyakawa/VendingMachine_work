# includeすることで、moduleで定義されているメソッドが使えるようになる
# 継承でもうまい抽象化ができないようなメソッドの共有で切り出す時に初めてでてくるぐらい
# classに分ける→抽象化できそうな段階で継承→それでもおさまらない時にmodule使う
module ItemManagement
  attr_reader :slot_money, :sales_money
  def initialize
    @slot_money = 0
    @sales_money = 0
    @managing = false
    p "初期設定：商品を入れ替えるための初期パスワードを設定してください"
    @password = gets.chomp.to_s
    puts "初期設定：いくつまでの商品を格納できるようにしますか？\n３以上の数を入力してください"
    loop do
      @item_limit = choice
      if @item_limit > 2
        break
      else
        p "有効な数字かつ3以上を入力してください"
      end
    end
  end

  def item_menu
    loop do
      sleep(0.5)
      puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
      puts "　＝管理機能＝ アイテムメニューです"
      display
      puts "ここまでの売上金額:#{self.sales_money}"
      puts "0:商品追加\n1:商品削除\n2:在庫補充\n3:メニューにもどる"
      case choice
      when 0
        if @items.size == @item_limit
          p "商品は#{@item_limit}個までしか格納できません、先に商品を削除してください"
        else
          item_add if check_password
        end
      when 1
        item_delete if check_password
      when 2
        item_restore if check_password
      when 3
        @managing = false
        break
      else
        p "有効な数字を入力してください"
      end
    end
  end

  def check_password
    p 'パスワードを入力してください'
    # パスワードの文字に制限があるなら正規表現でチェックすることはできそう
    # Railsだと、DBにできるので、そっちに保存するとかにはなりそう
    if gets.chomp.to_s == @password
      true
    else
      puts "パスワードが間違っています\n前の画面に戻ります"
      sleep(0.5)
      false
    end
  end

  def item_add
    p '値段を設定してください'
    price = gets.chomp.to_i
    p '商品名を設定してください'
    name = gets.chomp.to_s
    p '初期在庫数を設定してください'
    quantity = gets.chomp.to_i
    @items << {price: price, name: name, quantity: quantity, max: quantity}
  end

  def item_delete
    p "削除する商品の番号を入力"
    i = gets.chomp.to_i
    puts "商品番号#{i} 名前：#{@items[i][:name]}を削除しました"
    @items.delete_at(i)
  end

  def item_restore
    p "在庫補充する商品の番号を入力"
    i = gets.chomp.to_i
    @items[i][:quantity] = @items[i][:max]
    puts "商品番号：#{i} 名前：#{@items[i][:name]}を#{@items[i][:max]}個に補充しました"
  end

  def can_buy?(i)
    return false if @items[i][:quantity] <= 0

    if @managing

    else

    end
    (@managing && @items[i][:quantity] > 0) || (self.slot_money >= @items[i][:price] && @items[i][:quantity] > 0)
  end

  def display(items)
    puts "\n------------------------------------------\n"
    items.each_with_index do |item,i|
      puts "\n商品番号：#{i}\n名前：#{item[:name]}\n値段：#{item[:price]}\n在庫：#{item[:quantity]}"
      if can_buy?(i)
        puts ">購入できます<"
      else
        puts ">現在購入できません<"
      end
      puts "\n------------------------------------------\n"
    end
  end

  # こういう使い方は良さそう
  def choice
    gets.chomp.to_i
  end
end

class VendingMachineModel < ItemManagement
  include ItemManagement
  MONEY = [10, 50, 100, 500, 1000].freeze

  def initialize
    super
    # itemsがなければmoduleも動かないのは違和感ある
    @items = []
    @items << {price:120,name:'cola',quantity:5,max:5}
    @items << {price:100,name:'water',quantity:5,max:5}
    @items << {price:200,name:'redbull',quantity:5,max:5}
  end

  def throw_money(money)
    @slot_money += money
  end

  def return_money
    puts "#{@slot_money}円返却しました"
    @slot_money = 0
  end

  def get_item(i)
    @items[i][:quantity] -= 1
    @sales_money += @items[i][:price]
    @slot_money -= @items[i][:price]
    print "#{@items[i][:name]}を購入しました！"
    sleep(0.5)
    puts "ガタン"
    sleep(0.5)
  end
end

class VendingMachineInterface
  def initialize
    @vending_machine = VendingMachineModel.new
    super
    puts "いらっしゃいませ！！"
    menu
  end


  # 画面上入出力を切り出す方針もあり
  def menu
    loop do
      sleep(0.5)
      # 画面がある前提で出している
      puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
      puts 'メニューです‼'
      display
      puts "合計金額：#{@slot_money}"
      puts "0:コイン投入\n1:商品選択\n2:払い戻し\n3:商品管理画面\n4:購入を終了する"
      case choice
      when 0
        throw_money_interface
      when 1
        select_item
      when 2
        return_money
      when 3
        if check_password
          @managing = true
          item_menu
        end
      when 4
        return_money if @slot_money != 0
        puts "買い物を終了しました\nありがとうございました！"
        return
      else
        puts "適切な数字を入れてください"
        menu
      end
      puts "\n■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■-□-■\n"
    end
  end

  def throw_money_interface
    loop do
      puts "\n------------------------------------------\n"
      puts "$$ 現在の投入金額：#{@slot_money} $$"
      puts "お金を入れてください\n10, 50, 100, 500, 1000\n ※ 戻る場合は'99'を入力"
      case money = choice
      when *MONEY
        throw_money(money)
      when 99
        break
      else
        puts "#{money}"
        puts "入力が適切な数字ではありません\nメニューへ戻ります"
        break
      end
    end
  end

  def select_item
    puts '商品番号を選択してください'
    i = choice
    if i < @items.size && can_buy?(i)
      get_item(i)
    else
      if i >= @items.size
        puts "\n入力した商品番号は存在しません\n"
      else
        puts "\n商品の在庫がないか、投入金額が足りません\n"
      end
      puts "0:商品選択へ戻る\n1:メニューへ\n"
      select_item if choice == 0
    end
  end

end

vm = VendingMachineInterface.new
