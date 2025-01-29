class MissionReport {
  // Private constructor
  MissionReport._privateConstructor();

  // Static instance variable
  static final MissionReport _instance = MissionReport._privateConstructor();

  // Getter for the instance
  static MissionReport get instance => _instance;

  // List to store mission reports
  List<String> reports = [];

  // Method to add a new report
  void addReport(String report) {
    reports.add(report);
  }

  // Method to get all reports
  List<String> getReports() {
    return reports;
  }
}
