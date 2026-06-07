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
    if (_loadingMembers) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Members',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _members == null || _members!.isEmpty
                ? const Center(child: Text('No members found'))
                : ListView.separated(
                    itemCount: _members!.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final member = _members![index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (member['firstName'] ?? 'U')[0].toUpperCase(),
                          ),
                        ),
                        title: Text(member['firstName'] ?? 'Unknown'),
                        subtitle: Text('@${member['userName'] ?? 'unknown'}'),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generateInviteCode,
            icon: const Icon(Icons.person_add),
            label: const Text('INVITE PERSON'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
