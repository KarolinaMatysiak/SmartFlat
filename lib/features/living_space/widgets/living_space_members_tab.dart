import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_flat/features/living_space/services/living_space_invitation_service.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';

class LivingSpaceMembersTab extends StatefulWidget {
  final String spaceId;
  final List<String> memberIds;

  const LivingSpaceMembersTab({
    super.key,
    required this.spaceId,
    required this.memberIds,
  });

  @override
  State<LivingSpaceMembersTab> createState() => _LivingSpaceMembersTabState();
}

class _LivingSpaceMembersTabState extends State<LivingSpaceMembersTab> {
  List<Map<String, dynamic>>? _members;
  bool _loadingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await LivingSpaceService().getMembers(widget.memberIds);
      if (mounted) {
        setState(() {
          _members = members;
          _loadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingMembers = false);
      }
    }
  }

  Future<void> _generateInviteCode() async {
    try {
      final code = await LivingSpaceInvitationService().generateInvitationCode(
        widget.spaceId,
      );
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invite Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share this code with someone to join this space. It expires in 2 hours.',
              ),
              const SizedBox(height: 20),
              SelectableText(
                code,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copied to clipboard')),
                );
              },
              child: const Text('COPY'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate code: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loadingMembers) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.group_outlined, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Space Members',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_members == null || _members!.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(child: Text('No members found')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final member = _members![index];
                final name = member['firstName'] ?? 'User';
                final userName = member['userName'] ?? 'unknown';

                return Card(
                  color: Colors.white.withOpacity(0.7),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: cs.primary.withOpacity(0.1),
                      child: Text(
                        name[0].toUpperCase(),
                        style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('@$userName', style: TextStyle(color: cs.onSurface.withOpacity(0.6))),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _generateInviteCode,
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
              label: const Text(
                'INVITE PERSON',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          // Spacer for navigation bar
          SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
        ],
      ),
    );
  }
}

