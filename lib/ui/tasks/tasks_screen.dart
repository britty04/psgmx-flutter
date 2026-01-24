import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../services/supabase_db_service.dart';
import '../../core/theme/app_spacing.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final canPublish = userProvider.isCoordinator || (userProvider.isActualPlacementRep && !userProvider.isSimulating);

    if (canPublish) {
        return const _RepTasksView();
    }
    return const _StudentTasksView();
  }
}

// ==========================================
// STUDENT VIEW
// ==========================================

class _StudentTasksView extends StatefulWidget {
  const _StudentTasksView();

  @override
  State<_StudentTasksView> createState() => _StudentTasksViewState();
}

class _StudentTasksViewState extends State<_StudentTasksView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<SupabaseDbService>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _pickDate(),
            tooltip: "Select Date",
          )
        ],
      ),
      body: Column(
        children: [
          _DateSelectorHeader(
            date: _selectedDate, 
            onNext: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
            onPrev: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          Expanded(
            child: StreamBuilder<CompositeTask?>(
               stream: dbService.getDailyTask(dateStr),
               builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                 }
                 final task = snapshot.data;
                 
                 // Empty State
                 if (task == null) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 64, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                          const SizedBox(height: AppSpacing.md),
                          Text("No tasks for this day", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline)),
                       ],
                     ),
                   );
                 }
                 
                 // Tasks List
                 return ListView(
                   padding: const EdgeInsets.all(AppSpacing.screenPadding),
                   children: [
                      if (task.leetcodeUrl.isNotEmpty) 
                        _TaskCard(
                          type: "LeetCode",
                          color: Colors.orange,
                          title: "Daily Challenge",
                          content: task.leetcodeUrl,
                          isLink: true 
                        ),
                      const SizedBox(height: AppSpacing.md),
                      if (task.csTopic.isNotEmpty)
                        _TaskCard(
                          type: "Core Topic",
                          color: Theme.of(context).colorScheme.primary,
                          title: task.csTopic,
                          content: task.csTopicDescription,
                          isLink: false
                        ),
                   ],
                 );
               },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, 
      initialDate: _selectedDate, 
      firstDate: DateTime(2024), 
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
               backgroundColor: Theme.of(context).cardTheme.color,
            ),
          ), 
          child: child!,
        );
      }
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}

class _DateSelectorHeader extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateSelectorHeader({required this.date, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
       decoration: BoxDecoration(
         color: Theme.of(context).appBarTheme.backgroundColor,
         border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
       ),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
           Text(
             DateFormat('EEEE, MMMM d').format(date), 
             style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
           ),
           IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
         ],
       ),
     );
  }
}

class _TaskCard extends StatelessWidget {
  final String type;
  final Color color;
  final String title;
  final String content;
  final bool isLink;

  const _TaskCard({required this.type, required this.color, required this.title, required this.content, required this.isLink});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(4),
               ),
               child: Text(
                 type.toUpperCase(), 
                 style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)
               ),
             ),
             const SizedBox(height: AppSpacing.sm),
             Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
             Padding(
               padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
               child: const Divider(height: 1),
             ),
             if (isLink)
                InkWell(
                  onTap: () => launchUrl(Uri.parse(content)),
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content, 
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
             else
                Text(content, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// REP/COORD VIEW
// ==========================================

class _RepTasksView extends StatelessWidget {
  const _RepTasksView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Tasks"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "New Entry"),
              Tab(text: "Bulk Upload"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
             _SingleEntryForm(),
             _BulkUploadForm(),
          ],
        ),
      )
    );
  }
}

class _SingleEntryForm extends StatefulWidget {
  const _SingleEntryForm();

  @override
  State<_SingleEntryForm> createState() => _SingleEntryFormState();
}

class _SingleEntryFormState extends State<_SingleEntryForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  final _leetCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _FormSectionHeader(title: "Task Date"),
             ListTile(
               contentPadding: EdgeInsets.zero,
               title: Text(DateFormat('yyyy-MM-dd').format(_date)),
               subtitle: const Text("Tap to change"),
               leading: const Icon(Icons.calendar_today),
               trailing: const Icon(Icons.edit, size: 16),
               onTap: () async {
                 final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime(2026));
                 if (d != null) setState(() => _date = d);
               },
             ),
             const SizedBox(height: AppSpacing.lg),
             
             _FormSectionHeader(title: "Daily Challenge"),
             TextFormField(
               controller: _leetCtrl,
               decoration: const InputDecoration(labelText: "LeetCode URL", hintText: "https://..."),
               keyboardType: TextInputType.url,
             ),
             const SizedBox(height: AppSpacing.lg),

             _FormSectionHeader(title: "Core Topic"),
             TextFormField(
               controller: _topicCtrl,
               decoration: const InputDecoration(labelText: "Topic Title", hintText: "e.g., Virtual Memory"),
             ),
             const SizedBox(height: AppSpacing.sm),
             TextFormField(
               controller: _descCtrl,
               decoration: const InputDecoration(labelText: "Instructions / Description", alignLabelWithHint: true),
               maxLines: 4,
             ),
             
             const SizedBox(height: AppSpacing.xl),
             SizedBox(
               width: double.infinity,
               child: FilledButton(
                 onPressed: _isLoading ? null : _submit,
                 child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Text("Publish Task"),
               ),
             )
          ],
        )
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final task = CompositeTask(
        date: DateFormat('yyyy-MM-dd').format(_date),
        leetcodeUrl: _leetCtrl.text.trim(),
        csTopic: _topicCtrl.text.trim(),
        csTopicDescription: _descCtrl.text.trim(),
        motivationQuote: '', 
      );
      
      await Provider.of<SupabaseDbService>(context, listen: false).publishDailyTask(task);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Published successfully")));
         _leetCtrl.clear();
         _topicCtrl.clear();
         _descCtrl.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _FormSectionHeader extends StatelessWidget {
  final String title;
  const _FormSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
    );
  }
}

class _BulkUploadForm extends StatefulWidget {
  const _BulkUploadForm();

  @override
  State<_BulkUploadForm> createState() => _BulkUploadFormState();
}

class _BulkUploadFormState extends State<_BulkUploadForm> {
  bool _isLoading = false;
  String? _status;
  bool _isError = false;

  Future<void> _pickAndUpload() async {
     setState(() => _isLoading = true);
     try {
       final result = await FilePicker.platform.pickFiles(
         type: FileType.custom,
         allowedExtensions: ['xlsx', 'xls'],
         withData: true,
       );
       
       if (result == null) {
          setState(() { _isLoading = false; _status = "File selection cancelled"; _isError = false; });
          return;
       }

       final bytes = result.files.first.bytes;
       if (bytes == null) throw Exception("Could not read file.");

       final excel = Excel.decodeBytes(bytes);
       final tasks = <CompositeTask>[];

       for (var table in excel.tables.keys) {
          final sheet = excel.tables[table];
          if (sheet == null) continue;
          
          for (int i = 1; i < sheet.maxRows; i++) {
             final row = sheet.row(i);
             if (row.isEmpty) continue;
             
             try {
                if (row.isEmpty) continue;
                final dateValRaw = row[0]?.value;
                if (dateValRaw == null) continue;
                
                String dateStr;
                
                if (dateValRaw is DateCellValue) {
                   dateStr = DateFormat('yyyy-MM-dd').format(dateValRaw.asDateTimeLocal());
                } else if (dateValRaw is TextCellValue) {
                   dateStr = dateValRaw.value.toString().split('T')[0];
                } else {
                   dateStr = dateValRaw.toString().split('T')[0];
                }

                String leet = "";
                if (row.length > 1) {
                   final val = row[1]?.value;
                   if (val is TextCellValue) {
                      leet = val.value.toString(); // Wrapper handling
                   } else if (val != null) {
                      leet = val.toString();
                   }
                }
                final topic = row.length > 2 ? row[2]?.value?.toString() ?? "" : "";
                final desc = row.length > 3 ? row[3]?.value?.toString() ?? "" : "";

                tasks.add(CompositeTask(
                  date: dateStr, 
                  leetcodeUrl: leet, 
                  csTopic: topic, 
                  csTopicDescription: desc, 
                  motivationQuote: ''
                ));
             } catch (e) {
                // Skip malformed rows silently or log
             }
          }
       }

       if (tasks.isEmpty) throw Exception("No valid rows found. Check format: Date | URL | Topic | Desc");
       
       if (!mounted) return;
       final dbService = Provider.of<SupabaseDbService>(context, listen: false);
       await dbService.bulkPublishTasks(tasks);
       
       if (mounted) {
          setState(() { 
            _status = "Successfully processed ${tasks.length} tasks."; 
            _isError = false; 
          });
       }

     } catch (e) {
       if (context.mounted) {
         setState(() { _status = "Upload Failed: $e"; _isError = true; });
       }
     } finally {
       if (context.mounted) {
         setState(() => _isLoading = false);
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.upload_file_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text("Bulk Task Upload", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            const Text("Supported formats: .xlsx", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: AppSpacing.xl),
            
            _isLoading 
              ? const CircularProgressIndicator()
              : FilledButton.icon(
                  onPressed: _pickAndUpload, 
                  icon: const Icon(Icons.folder_open), 
                  label: const Text("Select Excel File")
                ),

            if (_status != null) ...[
               const SizedBox(height: AppSpacing.lg),
               Container(
                 padding: const EdgeInsets.all(AppSpacing.md),
                 decoration: BoxDecoration(
                   color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: _isError ? Colors.red.shade200 : Colors.green.shade200),
                 ),
                 child: Text(
                   _status!, 
                   style: TextStyle(color: _isError ? Colors.red.shade800 : Colors.green.shade800),
                   textAlign: TextAlign.center,
                 ),
               )
            ]
          ],
        ),
      ),
    );
  }
}
