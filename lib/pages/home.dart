
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:solana/solana.dart';

import '../models/NFT.dart';
import '../services/mint_nft.dart';
import '../services/nft_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _publicKey;
  String? _balance;
  SolanaClient? client;
  final storage = const FlutterSecureStorage();
  String CID = '';
  String name = '';
  String symbol = '';
  bool newFetch = false;

  bool _showNftExpanded = false;
  @override
  void initState() {
    super.initState();
    _readPk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              GoRouter.of(context).go("/config");
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text('Wallet Address',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 200,
                            child: Text(_publicKey ?? 'Loading...')),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            if (_publicKey != null) {
                              Clipboard.setData(
                                  ClipboardData(text: _publicKey!));
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    const Text('Balance',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_balance ?? 'Loading...'),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            _getBalance();
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mint NFT'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        GoRouter.of(context).go('/createNft', extra: client);
                      },
                    )
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Show Wallet NFTs'),
                    IconButton(
                      icon: Icon(_showNftExpanded
                          ? Icons.expand_less
                          : Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          _showNftExpanded = !_showNftExpanded;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            if (_showNftExpanded)
              SingleChildScrollView(
                  child: Container(
                      height: _showNftExpanded ? 200 : 0,
                      child: FutureBuilder<List<NFT>>(
                          future: fetchNfts(_publicKey!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              final nfts = snapshot.data;
                              return ListView.builder(
                                  itemCount: (nfts?.length ?? 0) + 1,
                                  itemBuilder: (context, index) {
                                    if (nfts == null) {
                                      return IconButton(
                                        icon: Icon(Icons.refresh),
                                        onPressed: () {
                                          fetchNfts(_publicKey!);
                                        },
                                      );
                                    }
                                    if (index < nfts.length) {
                                      final nft = nfts[index];
                                      return ListTile(
                                        onTap: () {},
                                        title: Text(nft.name ?? ""),
                                        subtitle: Text(nft.description ?? ""),
                                        leading: Image.network(nft.imageUrl ??
                                            "https://placehold.co/600x400/png"),
                                      );
                                    } else {
                                      return IconButton(
                                        icon: Icon(Icons.refresh),
                                        onPressed: () {
                                          setState(() {
                                            fetchNfts(_publicKey!);
                                          });
                                        },
                                      );
                                    }
                                  });
                            }
                          }))),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Log out'),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        GoRouter.of(context).go("/");
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _readPk() async {
    final mnemonic = await storage.read(key: 'mnemonic');
    if (mnemonic != null) {
      final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic);
      setState(() {
        _publicKey = keypair.address;
      });
      _initializeClient();
    }
  }

  void _initializeClient() async {
    String? rpcUrl;
    final network = await storage.read(key: "network");
    if (network == null || network == "") {
      await storage.write(key: 'network', value: "mainnet");
      rpcUrl = "https://api.mainnet-beta.solana.com";
      await storage.write(key: 'mainnetRpc', value: rpcUrl);
    } else if (network == "mainnet") {
      rpcUrl = await storage.read(key: "mainnetRpc");
    } else if (network == "devnet") {
      rpcUrl = await storage.read(key: "devnetRpc");
    }

    String wsUrl = rpcUrl!.replaceFirst('https', 'wss');
    client = SolanaClient(
      rpcUrl: Uri.parse(rpcUrl),
      websocketUrl: Uri.parse(wsUrl),
    );

    _getBalance();
  }

  void _getBalance() async {
    setState(() {
      _balance = null;
    });
    final getBalance = await client?.rpcClient
        .getBalance(_publicKey!, commitment: Commitment.confirmed);
    final balance = (getBalance!.value) / lamportsPerSol;
    setState(() {
      _balance = balance.toString();
    });
  }
}
