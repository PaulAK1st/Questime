import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/constants.dart';
import '../utilities/routes.dart';

class RewardsScreen extends StatefulWidget {
  final bool isGuest;

  const RewardsScreen({super.key, this.isGuest = false});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int _qtvouchers = 0;
  int _qtcoins = 0;
  int _qtrewards = 0; 
  bool _hasRedeemedFirstCoin = false;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _qtvouchers = prefs.getInt('qtvouchers') ?? 3; 
      _qtcoins = prefs.getInt('qtcoins') ?? 1; // Default of 1 
      _qtrewards = prefs.getInt('qtrewards') ?? 0; 
      _hasRedeemedFirstCoin = prefs.getBool('hasRedeemedFirstCoin') ?? false;
    });
  }

  Future<void> _saveRewards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('qtvouchers', _qtvouchers);
    await prefs.setInt('qtcoins', _qtcoins);
    await prefs.setInt('qtrewards', _qtrewards); 
    await prefs.setBool('hasRedeemedFirstCoin', _hasRedeemedFirstCoin);
  }

  // Sync quantity in Rewards Inventory
  int get userMedals => _qtcoins; 

  void _showRedeemConfirmDialog({required bool isRedeemingCoffee}) {
    final bool hasEnoughCoins = _qtcoins >= 1;
    final bool hasEnoughRewards = _qtrewards >= 1;
    
    if (isRedeemingCoffee && !hasEnoughCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least 1 QT coin to redeem a QT reward!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!isRedeemingCoffee && !hasEnoughRewards) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least 1 QT reward to redeem a QT coin!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.amber[50]!, Colors.orange[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Confirm Redemption',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isRedeemingCoffee 
                    ? 'Are you sure you want to redeem 1 QT coin for a QT reward?'
                    : 'Are you sure you want to redeem 1 QT reward for a QT coin?',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (isRedeemingCoffee) {
                            _redeemCoffeeReward();
                          } else {
                            _redeemCoinReward();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Redeem!'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

  void _redeemCoffeeReward() {
    setState(() {
      _qtcoins--; // Reduce 1 QT coin from inventory
      _qtrewards++; // Add 1 QT reward to inventory
    });
    _saveRewards();

    // Congratulations dialog with coffee
    _showRedeemDialog(rewardType: 'coffee');
  }

  void _redeemCoinReward() {
    setState(() {
      _qtrewards--; // Reduce 1 QT reward from inventory
      _qtcoins++; // Add 1 QT coin to inventory
    });
    _saveRewards();

    // Congratulations dialog with coin 
    _showRedeemDialog(rewardType: 'coin');
  }

  void _showRedeemDialog({required String rewardType}) {
    final bool isCoffee = rewardType == 'coffee';
    
  showDialog(
    context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.amber[50]!, Colors.orange[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                
                // Title
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Message
                const Text(
                  'You got a reward:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Reward display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reward image
                      Image.asset(
                        isCoffee ? '/images/coffee.png' : '/images/qtcoin.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            isCoffee ? Icons.local_cafe : Icons.monetization_on,
                            color: isCoffee ? Colors.brown : Colors.orange,
                            size: 40,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isCoffee ? 'QT Reward!' : 'QT Coin!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isCoffee ? Colors.brown : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 16,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
              ),
            ),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          '/images/logo_sym.png',
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.quiz, size: 24, color: Colors.white);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'QuesTime',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Return to title button on right
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.welcome,
                              (route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: const Text(
                            'Return to title',
                            style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Treasure Chest',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: AppConstants.accentColor,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Your medals: ',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          Text(
                            '$userMedals',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                                color: AppConstants.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Main content area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Rewards',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Single Rewards Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Redeemable Reward Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Redeemable Rewards',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // QT Reward (Coffee) pay 1 coin
                                Row(
                                  children: [
                                    Image.asset(
                                      '/images/coffee.png',
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.local_cafe,
                                          color: Colors.brown,
                                          size: 40,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Reward: QT reward',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.brown,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Condition: Purchase with 1 QT coin',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.amber[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: _qtcoins >= 1 ? () => _showRedeemConfirmDialog(isRedeemingCoffee: true) : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.brown,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Redeem!',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // QT Coin pay 1 reward
                                Row(
                                  children: [
                                    Image.asset(
                                      '/images/qtcoin.png',
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.monetization_on,
                                          color: Colors.orange,
                                          size: 40,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Reward: QT coin',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Condition: Purchase with 1 QT reward',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.amber[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: _qtrewards >= 1 ? () => _showRedeemConfirmDialog(isRedeemingCoffee: false) : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Redeem!',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Current Rewards 
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rewards Inventory',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // QT Coins
                                Row(
                                  children: [
                                    Image.asset(
                                      '/images/qtcoin.png',
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.monetization_on,
                                          color: Colors.orange,
                                          size: 40,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text(
                                                'QT coin',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'Qty: $_qtcoins',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    ),
                                                    ),
                                                  ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                        ),
                                      ],
                                    ),
                                  
                                if (_qtrewards > 0) ...[
                                  const SizedBox(height: 12),
                                  // QT Rewards Coffee
                                  Row(
                                    children: [
                                      Image.asset(
                                        '/images/coffee.png',
                                        width: 40,
                                        height: 40,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.local_cafe,
                                            color: Colors.brown,
                                            size: 40,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  'QT reward',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.brown,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.brown,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    'Qty: $_qtrewards',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  
                                const SizedBox(height: 8),
                                Text(
                                  'Description: Congratulations! This is reward for your quest-ion journey!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    
                    const SizedBox(height: 24),
                    
                    // Congratulations message for first coin
                    if (_qtcoins > 0 && !_hasRedeemedFirstCoin) 
                      _buildCongratulationsCard(),
                    
                    const SizedBox(height: 24),
                    
                    // How to earn more
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              Text(
                                'How to Earn More Rewards',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete surveys with reward badges \nParticipate in community challenges\n',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Bottom navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA), 
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Explore
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.explore);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          color: Colors.grey[600],
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Profile
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.profile);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.grey[600],
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Rewards (highlighted)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.amber[600], 
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rewards',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[600],
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildCongratulationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[100]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[300]!),
      ),
      child: Column(
        children: [
          // QT Coin image 
          Image.asset(
            '/images/qtcoin.png',
            width: 80,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.monetization_on,
                size: 60,
                color: Colors.amber,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Congratulation for your first treasure! This is just the beginning of survey journey!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.purple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasRedeemedFirstCoin = true;
              });
              _saveRewards();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}