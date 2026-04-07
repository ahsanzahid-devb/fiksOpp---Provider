import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/job_list_screen.dart';
import 'package:handyman_provider_flutter/utils/city_lookup_cache.dart';
import 'package:nb_utils/nb_utils.dart';

import '../jobRequest/components/job_item_widget.dart';
import '../jobRequest/models/post_job_data.dart';

class JobListComponent extends StatefulWidget {
  final List<PostJobData> list;

  const JobListComponent({super.key, required this.list});

  @override
  State<JobListComponent> createState() => _JobListComponentState();
}

class _JobListComponentState extends State<JobListComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || appStore.stateId <= 0) return;
      await CityLookupCache.warmForStateIfNeeded(
          appStore.stateId, (sid) => getCityList({'state_id': sid}));
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    if (list.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: languages.jobRequestList,
          list: list.validate(),
          onTap: () {
            JobListScreen().launch(context);
          },
        ),
        AnimatedListView(
          itemCount: list.validate().length,
          shrinkWrap: true,
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          itemBuilder: (_, i) => JobItemWidget(data: list[i]),
        ),
      ],
    );
  }
}
