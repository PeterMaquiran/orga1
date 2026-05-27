import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../shared/navigationBar.dart';

class _BoardItem {
  const _BoardItem({
    required this.title,
    required this.accent,
    this.subtitle,
  });

  final String title;
  final Color accent;
  final String? subtitle;
}

class BoardsScreen extends StatelessWidget {
  const BoardsScreen({super.key});

  static const Color _iosGroupedBg = Color(0xFFF2F2F7);

  static const List<_BoardItem> _boards = [
    _BoardItem(
      title: 'Personal',
      accent: Color(0xFF0B84FF),
      subtitle: '3 lists',
    ),
    _BoardItem(
      title: 'Work projects',
      accent: Color(0xFF34C759),
      subtitle: '5 lists',
    ),
    _BoardItem(
      title: 'Ideas',
      accent: Color(0xFFFF9F0A),
      subtitle: '2 lists',
    ),
    _BoardItem(
      title: 'Shared with team',
      accent: Color(0xFFAF52DE),
      subtitle: '4 lists',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final secondaryLabel = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Scaffold(
      extendBody: true,
      body: ColoredBox(
        color: _iosGroupedBg,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, safeTop + 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Boards',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.37,
                    height: 1.1,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
              sliver: SliverToBoxAdapter(
                child: CupertinoListSection.insetGrouped(
                  backgroundColor: _iosGroupedBg,
                  header: Text(
                    'Your workspaces',
                    style: TextStyle(
                      color: secondaryLabel,
                      fontSize: 13,
                      letterSpacing: -0.08,
                    ),
                  ),
                  children: [
                    for (final b in _boards)
                      CupertinoListTile.notched(
                        leading: Center(
                          child: Container(
                            width: 4,
                            height: 28,
                            decoration: BoxDecoration(
                              color: b.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        leadingSize: 12,
                        title: Text(
                          b.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.41,
                          ),
                        ),
                        subtitle: b.subtitle != null
                            ? Text(
                                b.subtitle!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: secondaryLabel,
                                  letterSpacing: -0.24,
                                ),
                              )
                            : null,
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {},
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
              sliver: SliverToBoxAdapter(
                child: CupertinoListSection.insetGrouped(
                  backgroundColor: _iosGroupedBg,
                  children: [
                    CupertinoListTile.notched(
                      leading: Icon(
                        CupertinoIcons.add_circled,
                        color: CupertinoColors.activeBlue.resolveFrom(context),
                        size: 26,
                      ),
                      title: Text(
                        'Create board',
                        style: TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.activeBlue.resolveFrom(context),
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.41,
                        ),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FloatingNavBar(),
    );
  }
}
