import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/constants/demo_data.dart';
import '../../models/squad.dart';

final squadProvider = Provider<SquadModel>((ref) => DemoData.initialSquad);
