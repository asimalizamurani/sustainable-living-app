import 'package:flutter/material.dart';

class EcoFriendlyScreen extends StatelessWidget {
  const EcoFriendlyScreen({super.key});

  final List<Map<String, String>> products = const [
    {
      'name': 'Reusable Water Bottle',
      'desc': 'Ditch single-use plastics with a stainless steel or glass bottle.',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Bamboo Toothbrush',
      'desc': 'A biodegradable alternative to plastic toothbrushes.',
      'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Organic Cotton Tote Bag',
      'desc': 'Say no to plastic bags with a reusable tote.',
      'image': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Solar Power Bank',
      'desc': 'Charge your devices with clean, renewable energy.',
      'image': 'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'Compost Bin',
      'desc': 'Turn food scraps into nutrient-rich compost for your garden.',
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
    },
    {
      'name': 'LED Light Bulbs',
      'desc': 'Save energy and money with long-lasting LED bulbs.',
      'image': 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Friendly Products'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 18),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    product['image']!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product['desc']!,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
