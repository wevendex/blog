import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/themes/app_theme.dart';
import '../../widgets/custom_button.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<ShopItem> _shopItems = [
    ShopItem(
      id: 'coins_small',
      name: '金币包（小）',
      description: '1000金币',
      price: 6.0,
      coins: 1000,
      icon: Icons.monetization_on,
    ),
    ShopItem(
      id: 'coins_medium',
      name: '金币包（中）',
      description: '5000金币',
      price: 25.0,
      coins: 5000,
      icon: Icons.monetization_on,
    ),
    ShopItem(
      id: 'coins_large',
      name: '金币包（大）',
      description: '10000金币',
      price: 45.0,
      coins: 10000,
      icon: Icons.monetization_on,
    ),
    ShopItem(
      id: 'vip_monthly',
      name: 'VIP月卡',
      description: '每日签到双倍奖励',
      price: 30.0,
      coins: 0,
      icon: Icons.card_membership,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('商城'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 用户金币显示
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.black,
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '当前金币: 10,000',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              
              // 商品列表
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: _shopItems.length,
                  itemBuilder: (context, index) {
                    return _buildShopItem(_shopItems[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopItem(ShopItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.goldColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              item.icon,
              size: 48.sp,
              color: AppTheme.goldColor,
            ),
            Column(
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            CustomButton(
              onPressed: () => _purchaseItem(item),
              height: 36.h,
              child: Text(
                '¥${item.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseItem(ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(
          '购买确认',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '确定要购买 ${item.name} 吗？',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(item);
            },
            height: 32.h,
            child: Text('确认购买'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(ShopItem item) {
    // 这里应该调用支付SDK进行实际支付
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('购买成功！'),
        backgroundColor: AppTheme.goldColor,
      ),
    );
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final int coins;
  final IconData icon;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.coins,
    required this.icon,
  });
}