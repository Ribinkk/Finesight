import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String name;
  final double price;
  final String frequency;
  final String description;

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.frequency,
    required this.description,
  });
}

class SubscriptionService {
  final String name;
  final String logoUrl;
  final Color color;
  final List<SubscriptionPlan> plans;

  const SubscriptionService({
    required this.name,
    required this.logoUrl,
    required this.color,
    required this.plans,
  });
}

class SubscriptionData {
  static const List<SubscriptionService> services = [
    // --- Streaming (India & Global) ---
    SubscriptionService(
      name: 'Netflix',
      logoUrl: 'assets/images/logos/netflix.png',
      color: Color(0xFFE50914),
      plans: [
        SubscriptionPlan(
          name: 'Mobile',
          price: 149,
          frequency: 'Monthly',
          description: '480p, Phone/Tablet',
        ),
        SubscriptionPlan(
          name: 'Basic',
          price: 199,
          frequency: 'Monthly',
          description: '720p, 1 Device',
        ),
        SubscriptionPlan(
          name: 'Standard',
          price: 499,
          frequency: 'Monthly',
          description: '1080p, 2 Devices',
        ),
        SubscriptionPlan(
          name: 'Premium',
          price: 649,
          frequency: 'Monthly',
          description: '4K+HDR, 4 Devices',
        ),
      ],
    ),
    SubscriptionService(
      name: 'Spotify',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Spotify_logo_with_text.svg/960px-Spotify_logo_with_text.svg.png',
      color: Color(0xFF1DB954),
      plans: [
        SubscriptionPlan(
          name: 'Student',
          price: 59,
          frequency: 'Monthly',
          description: 'Verified students',
        ),
        SubscriptionPlan(
          name: 'Premium Lite',
          price: 139,
          frequency: 'Monthly',
          description: 'Ad-free music',
        ),
        SubscriptionPlan(
          name: 'Individual',
          price: 199,
          frequency: 'Monthly',
          description: 'Ad-free, 320kbps',
        ),
        SubscriptionPlan(
          name: 'Family',
          price: 179,
          frequency: 'Monthly',
          description: '6 Accounts',
        ),
      ],
    ),
    SubscriptionService(
      name: 'YouTube Premium',
      logoUrl: 'assets/images/logos/youtube.png',
      color: Color(0xFFFF0000),
      plans: [
        SubscriptionPlan(
          name: 'Student',
          price: 89,
          frequency: 'Monthly',
          description: 'Verified students',
        ),
        SubscriptionPlan(
          name: 'Individual',
          price: 149,
          frequency: 'Monthly',
          description: 'Ad-free, Background play',
        ),
        SubscriptionPlan(
          name: 'Family',
          price: 299,
          frequency: 'Monthly',
          description: '5 Family members',
        ),
        SubscriptionPlan(
          name: 'Annual',
          price: 1290,
          frequency: 'Yearly',
          description: 'Individual Annual',
        ),
      ],
    ),
    SubscriptionService(
      name: 'Amazon Prime',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Amazon_Prime_logo_%282024%29.svg/1280px-Amazon_Prime_logo_%282024%29.svg.png',
      color: Color(0xFF00A8E1),
      plans: [
        SubscriptionPlan(
          name: 'Monthly',
          price: 299,
          frequency: 'Monthly',
          description: 'Prime Video, Shipping',
        ),
        SubscriptionPlan(
          name: 'Shopping Edition',
          price: 399,
          frequency: 'Yearly',
          description: 'Shipping only',
        ),
        SubscriptionPlan(
          name: 'Prime Lite',
          price: 799,
          frequency: 'Yearly',
          description: 'SD Video + Shipping',
        ),
        SubscriptionPlan(
          name: 'Annual',
          price: 1499,
          frequency: 'Yearly',
          description: 'Full Prime benefits',
        ),
      ],
    ),
    SubscriptionService(
      name: 'Disney+ Hotstar',
      logoUrl: 'assets/images/logos/disney.png',
      color: Color(0xFF0F1014),
      plans: [
        SubscriptionPlan(
          name: 'Super',
          price: 899,
          frequency: 'Yearly',
          description: '1080p, 2 Devices, Ads',
        ),
        SubscriptionPlan(
          name: 'Premium Monthly',
          price: 299,
          frequency: 'Monthly',
          description: '4K, 4 Devices',
        ),
        SubscriptionPlan(
          name: 'Premium Yearly',
          price: 1499,
          frequency: 'Yearly',
          description: '4K, 4 Devices',
        ),
      ],
    ),
    SubscriptionService(
      name: 'JioCinema',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/1/14/Jiocinema.png',
      color: Color(0xFFD40B5E),
      plans: [
        SubscriptionPlan(
          name: 'Premium Monthly',
          price: 29,
          frequency: 'Monthly',
          description: 'Ad-free (except Sports)',
        ),
        SubscriptionPlan(
          name: 'Family',
          price: 89,
          frequency: 'Monthly',
          description: '4 Screens',
        ),
        SubscriptionPlan(
          name: 'Annual',
          price: 299,
          frequency: 'Yearly',
          description: 'Premium Annual',
        ),
      ],
    ),
    SubscriptionService(
      name: 'SonyLIV',
      logoUrl:
          'https://res.cloudinary.com/dhmw8d3ka/image/upload/f_auto,q_auto,fl_lossy/v1743572898/D2C%20Merchants/Sonyliv/Sonyliv_z2lddj.webp',
      color: Color(0xFFF05125),
      plans: [
        SubscriptionPlan(
          name: 'Mobile Only',
          price: 599,
          frequency: 'Yearly',
          description: '1 Screen, Mobile',
        ),
        SubscriptionPlan(
          name: 'Premium Monthly',
          price: 299,
          frequency: 'Monthly',
          description: 'All Content, 1080p',
        ),
        SubscriptionPlan(
          name: 'Premium Yearly',
          price: 999,
          frequency: 'Yearly',
          description: 'All Content, 2 Screens',
        ),
      ],
    ),
    SubscriptionService(
      name: 'Zee5',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Zee5_Logo_2018-2025.svg/512px-Zee5_Logo_2018-2025.svg.png',
      color: Color(0xFF7D167E),
      plans: [
        SubscriptionPlan(
          name: 'Premium HD',
          price: 699,
          frequency: 'Yearly',
          description: 'Originals, Movies',
        ),
        SubscriptionPlan(
          name: 'Premium 4K',
          price: 1199,
          frequency: 'Yearly',
          description: '4K, Originals',
        ),
      ],
    ),
    SubscriptionService(
      name: 'Apple One',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Apple_One_logo.svg/1200px-Apple_One_logo.svg.png',
      color: Colors.black,
      plans: [
        SubscriptionPlan(
          name: 'Individual',
          price: 195,
          frequency: 'Monthly',
          description: 'Music, TV+, Arcade, iCloud+ (50GB)',
        ),
        SubscriptionPlan(
          name: 'Family',
          price: 365,
          frequency: 'Monthly',
          description: 'Share with 5 people, 200GB',
        ),
      ],
    ),

    // --- Food & Delivery ---
    SubscriptionService(
      name: 'Zomato Gold',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Zomato_Logo.svg/1024px-Zomato_Logo.svg.png',
      color: Color(0xFFCB202D),
      plans: [
        SubscriptionPlan(
          name: '3 Months',
          price: 99,
          frequency: 'Quarterly',
          description: 'Free Delivery, Discounts',
        ),
        SubscriptionPlan(
          name: 'Annual',
          price: 199,
          frequency: 'Yearly',
          description: 'Free Delivery',
        ),
      ],
    ),
    SubscriptionService(
      name: 'Swiggy One',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/1/12/Swiggy_logo.svg/1200px-Swiggy_logo.svg.png',
      color: Color(0xFFFC8019),
      plans: [
        SubscriptionPlan(
          name: 'Lite (3 Mo)',
          price: 99,
          frequency: 'Quarterly',
          description: '10 Free Deliveries',
        ),
        SubscriptionPlan(
          name: 'Membership (3 Mo)',
          price: 299,
          frequency: 'Quarterly',
          description: 'Unlimited Free Delivery',
        ),
        SubscriptionPlan(
          name: 'Annual',
          price: 899,
          frequency: 'Yearly',
          description: 'Unlimited Free Delivery',
        ),
      ],
    ),

    // --- Tech & Productivity ---
    SubscriptionService(
      name: 'Google One',
      logoUrl: 'assets/images/logos/googleone.png',
      color: Color(0xFF1A73E8),
      plans: [
        SubscriptionPlan(
          name: 'Basic (100GB)',
          price: 130,
          frequency: 'Monthly',
          description: '100 GB Storage',
        ),
        SubscriptionPlan(
          name: 'Standard (200GB)',
          price: 210,
          frequency: 'Monthly',
          description: '200 GB Storage',
        ),
        SubscriptionPlan(
          name: 'Premium (2TB)',
          price: 650,
          frequency: 'Monthly',
          description: '2 TB Storage',
        ),
        SubscriptionPlan(
          name: 'Basic Annual',
          price: 1300,
          frequency: 'Yearly',
          description: '100 GB (Save 17%)',
        ),
      ],
    ),
    SubscriptionService(
      name: 'Microsoft 365',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Microsoft_365_%282022%29.svg/1024px-Microsoft_365_%282022%29.svg.png',
      color: Color(0xFFEA3E23),
      plans: [
        SubscriptionPlan(
          name: 'Personal',
          price: 489,
          frequency: 'Monthly',
          description: '1 Person, 1TB Cloud',
        ),
        SubscriptionPlan(
          name: 'Family',
          price: 619,
          frequency: 'Monthly',
          description: 'Up to 6 People, 6TB Cloud',
        ),
        SubscriptionPlan(
          name: 'Personal Annual',
          price: 4899,
          frequency: 'Yearly',
          description: 'Save 16%',
        ),
      ],
    ),
    SubscriptionService(
      name: 'ChatGPT Plus',
      logoUrl: 'assets/images/logos/chatgpt.png',
      color: Color(0xFF10A37F),
      plans: [
        SubscriptionPlan(
          name: 'Plus',
          price: 1999,
          frequency: 'Monthly',
          description: 'GPT-4 Access, DALL-E',
        ),
      ],
    ),
    SubscriptionService(
      name: 'LinkedIn Premium',
      logoUrl: 'assets/images/logos/linkedin.png',
      color: Color(0xFF0A66C2),
      plans: [
        SubscriptionPlan(
          name: 'Career',
          price: 1533,
          frequency: 'Monthly',
          description: 'Job insights, Messaging',
        ),
        SubscriptionPlan(
          name: 'Business',
          price: 2200,
          frequency: 'Monthly',
          description: 'Business insights',
        ),
      ],
    ),

    // --- Gaming ---
    SubscriptionService(
      name: 'Xbox Game Pass',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Xbox_Game_Pass_logo_2020.svg/1200px-Xbox_Game_Pass_logo_2020.svg.png',
      color: Color(0xFF107C10),
      plans: [
        SubscriptionPlan(
          name: 'PC',
          price: 349,
          frequency: 'Monthly',
          description: 'Hundreds of PC games',
        ),
        SubscriptionPlan(
          name: 'Core',
          price: 349,
          frequency: 'Monthly',
          description: 'Online console multiplayer',
        ),
        SubscriptionPlan(
          name: 'Ultimate',
          price: 549,
          frequency: 'Monthly',
          description: 'Console, PC, Cloud',
        ),
      ],
    ),
    SubscriptionService(
      name: 'PlayStation Plus',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/PlayStation_Plus_logo_and_wordmark.svg/1200px-PlayStation_Plus_logo_and_wordmark.svg.png',
      color: Color(0xFF00419D),
      plans: [
        SubscriptionPlan(
          name: 'Essential',
          price: 499,
          frequency: 'Monthly',
          description: 'Monthly games, Online',
        ),
        SubscriptionPlan(
          name: 'Extra',
          price: 749,
          frequency: 'Monthly',
          description: 'Game Catalog',
        ),
        SubscriptionPlan(
          name: 'Deluxe',
          price: 849,
          frequency: 'Monthly',
          description: 'Classics Catalog',
        ),
      ],
    ),
  ];

  static String? getLogoUrl(String serviceName) {
    try {
      final service = services.firstWhere(
        (s) => serviceName.toLowerCase().contains(s.name.toLowerCase()),
      );
      return service.logoUrl.isNotEmpty ? service.logoUrl : null;
    } catch (_) {
      return null;
    }
  }

  static Color getColor(String serviceName) {
    try {
      final service = services.firstWhere(
        (s) => serviceName.toLowerCase().contains(s.name.toLowerCase()),
      );
      return service.color;
    } catch (_) {
      return const Color(0xFF009B6E);
    }
  }
}
