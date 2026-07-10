import '../models/complaint.dart';

const List<Complaint> complaints = [
  Complaint(
    id: 'PG-2026-0148',
    category: 'Damaged Road',
    village: 'Bhondsi',
    description: 'Road damaged near Government School gate.',
    date: '06 Jul 2026',
    status: ComplaintStatus.pending,
    officer: 'Not assigned',
    location: '28.3521, 77.0642',
  ),
  Complaint(
    id: 'PG-2026-0142',
    category: 'Street Light',
    village: 'Sohna',
    description: 'Main chowk street light is not working.',
    date: '04 Jul 2026',
    status: ComplaintStatus.inProgress,
    officer: 'Rajesh Kumar, JE',
    location: '28.2474, 77.0659',
  ),
  Complaint(
    id: 'PG-2026-0130',
    category: 'Drainage',
    village: 'Badshahpur',
    description: 'Drain blocked near panchayat ghar.',
    date: '29 Jun 2026',
    status: ComplaintStatus.resolved,
    officer: 'Sunita Malik, ASO',
    location: '28.3975, 77.0417',
  ),
];
