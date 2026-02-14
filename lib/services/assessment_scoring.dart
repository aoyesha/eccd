class AssessmentScoring {
  static Map<String, dynamic> calculate({
    required double ageInYears,
    required int gmdRaw,
    required int fmsRaw,
    required int shdRaw,
    required int rlRaw,
    required int elRaw,
    required int cdRaw,
    required int sedRaw,
  }) {
    final gmdSS = _getScaledScore(ageInYears, 'gmd', gmdRaw);
    final fmsSS = _getScaledScore(ageInYears, 'fms', fmsRaw);
    final shdSS = _getScaledScore(ageInYears, 'shd', shdRaw);
    final rlSS  = _getScaledScore(ageInYears, 'rl', rlRaw);
    final elSS  = _getScaledScore(ageInYears, 'el', elRaw);
    final cdSS  = _getScaledScore(ageInYears, 'cd', cdRaw);
    final sedSS = _getScaledScore(ageInYears, 'sed', sedRaw);

    final rawTotal = gmdRaw + fmsRaw + shdRaw + rlRaw + elRaw + cdRaw + sedRaw;

    final summaryScaled =
        gmdSS + fmsSS + shdSS + rlSS + elSS + cdSS + sedSS;

    final standardScore = _getStandardScore(summaryScaled);

    return {
      // DOMAIN TOTALS
      "gmd_total": gmdRaw,
      "gmd_ss": gmdSS,
      "gmd_interpretation": _scaledInterpretation(gmdSS),

      "fms_total": fmsRaw,
      "fms_ss": fmsSS,
      "fms_interpretation": _scaledInterpretation(fmsSS),

      "shd_total": shdRaw,
      "shd_ss": shdSS,
      "shd_interpretation": _scaledInterpretation(shdSS),

      "rl_total": rlRaw,
      "rl_ss": rlSS,
      "rl_interpretation": _scaledInterpretation(rlSS),

      "el_total": elRaw,
      "el_ss": elSS,
      "el_interpretation": _scaledInterpretation(elSS),

      "cd_total": cdRaw,
      "cd_ss": cdSS,
      "cd_interpretation": _scaledInterpretation(cdSS),

      "sed_total": sedRaw,
      "sed_ss": sedSS,
      "sed_interpretation": _scaledInterpretation(sedSS),

      // GLOBAL
      "raw_score": rawTotal,
      "summary_scaled_score": summaryScaled,
      "standard_score": standardScore,
      "interpretation": _overallInterpretation(standardScore),
    };
  }

  // Age router
  static int _getScaledScore(double age, String domain, int raw) {
    if (age >= 3.1 && age <= 4.0) {
      return _age3to4(domain, raw);
    }
    if (age >= 4.1 && age <= 5.0) {
      return _age4to5(domain, raw);
    }
    if (age >= 5.1 && age <= 5.11) {
      return _age5to511(domain, raw);
    }
    return 0;
  }

  // AGE 3.1 – 4.0
  static int _age3to4(String d, int r) {
    switch (d) {
      case 'gmd':
        if (r <= 3) return 1;
        if (r == 4) return 2;
        if (r == 5) return 3;
        if (r == 6) return 5;
        if (r == 7) return 6;
        if (r == 8) return 7;
        if (r == 9) return 8;
        if (r == 10) return 10;
        if (r == 11) return 11;
        if (r == 12) return 12;
        if (r == 13) return 14;
        break;

      case 'fms':
        if (r <= 3) return 2;
        if (r == 4) return 4;
        if (r == 5) return 5;
        if (r == 6) return 7;
        if (r == 7) return 9;
        if (r == 8) return 10;
        if (r == 9) return 12;
        if (r == 10) return 14;
        if (r == 11) return 15;
        break;

      case 'shd':
        if (r <= 9) return 1;
        if (r == 10) return 2;
        if (r == 11) return 3;
        if (r == 12) return 4;
        if (r <= 14) return 5;
        if (r == 15) return 6;
        if (r == 16) return 7;
        if (r == 17) return 8;
        if (r <= 19) return 9;
        if (r == 20) return 10;
        if (r == 21) return 11;
        if (r == 22) return 12;
        if (r <= 24) return 13;
        if (r == 25) return 14;
        if (r == 26) return 15;
        if (r == 27) return 16;
        break;

      case 'rl':
        if (r <= 1) return 3;
        if (r == 2) return 5;
        if (r == 3) return 7;
        if (r == 4) return 10;
        if (r == 5) return 12;
        break;

      case 'el':
        if (r <= 2) return 1;
        if (r == 3) return 3;
        if (r == 4) return 4;
        if (r == 5) return 6;
        if (r == 6) return 9;
        if (r == 7) return 11;
        if (r == 8) return 13;
        break;

      case 'cd':
        if (r == 0) return 3;
        if (r == 1) return 4;
        if (r <= 3) return 5;
        if (r == 4) return 6;
        if (r == 5) return 7;
        if (r == 6) return 8;
        if (r == 7) return 9;
        if (r <= 9) return 10;
        if (r == 10) return 11;
        if (r == 12) return 13;
        if (r <= 14) return 14;
        if (r == 15) return 15;
        if (r == 16) return 16;
        if (r == 17) return 17;
        if (r == 18) return 18;
        if (r <= 21) return 19;
        break;

      case 'sed':
        if (r <= 9) return 1;
        if (r <= 11) return 2;
        if (r == 12) return 3;
        if (r == 13) return 4;
        if (r == 14) return 5;
        if (r == 15) return 6;
        if (r == 16) return 7;
        if (r <= 18) return 8;
        if (r == 19) return 9;
        if (r == 20) return 10;
        if (r == 21) return 11;
        if (r == 22) return 12;
        if (r == 23) return 13;
        if (r == 24) return 14;
        break;
    }
    return 0;
  }

  // AGE 4.1 – 5.0
  static int _age4to5(String d, int r) {
    switch (d) {
      case 'gmd':
        if (r <= 5) return 1;
        if (r == 6) return 2;
        if (r == 7) return 4;
        if (r == 8) return 5;
        if (r == 9) return 7;
        if (r == 10) return 8;
        if (r == 11) return 10;
        if (r == 12) return 11;
        if (r == 13) return 13;
        break;

      case 'fms':
        if (r <= 3) return 1;
        if (r == 4) return 2;
        if (r == 5) return 4;
        if (r == 6) return 5;
        if (r == 7) return 7;
        if (r == 8) return 9;
        if (r == 9) return 10;
        if (r == 10) return 12;
        if (r == 11) return 14;
        break;

      case 'shd':
        if (r <= 15) return 1;
        if (r == 16) return 2;
        if (r == 17) return 3;
        if (r == 18) return 4;
        if (r == 19) return 5;
        if (r == 20) return 6;
        if (r == 21) return 8;
        if (r == 22) return 9;
        if (r == 23) return 10;
        if (r == 24) return 11;
        if (r == 25) return 12;
        if (r == 26) return 13;
        if (r == 27) return 14;
        break;

      case 'rl':
        if (r <= 1) return 1;
        if (r == 2) return 3;
        if (r == 3) return 6;
        if (r == 4) return 9;
        if (r == 5) return 11;
        break;

      case 'el':
        if (r <= 5) return 2;
        if (r == 6) return 5;
        if (r == 7) return 8;
        if (r == 8) return 11;
        break;

      case 'cd':
        if (r == 0) return 1;
        if (r == 1) return 2;
        if (r <= 3) return 3;
        if (r == 4) return 4;
        if (r == 5) return 5;
        if (r <= 7) return 6;
        if (r == 8) return 7;
        if (r <= 10) return 8;
        if (r == 11) return 9;
        if (r == 12) return 10;
        if (r <= 14) return 11;
        if (r == 15) return 12;
        if (r <= 17) return 13;
        if (r == 18) return 14;
        if (r <= 20) return 15;
        if (r == 21) return 16;
        break;

      case 'sed':
        if (r <= 13) return 1;
        if (r == 14) return 2;
        if (r == 15) return 3;
        if (r == 16) return 4;
        if (r == 17) return 5;
        if (r == 18) return 7;
        if (r == 19) return 8;
        if (r == 20) return 9;
        if (r == 21) return 10;
        if (r == 22) return 11;
        if (r == 23) return 12;
        if (r == 24) return 13;
        break;
    }
    return 0;
  }

  // AGE 5.1 – 5.11
  static int _age5to511(String d, int r) {
    switch (d) {
      case 'gmd':
        if (r <= 10) return 1;
        if (r == 11) return 4;
        if (r == 12) return 7;
        if (r == 13) return 11;
        break;

      case 'fms':
        if (r <= 5) return 1;
        if (r == 6) return 3;
        if (r == 7) return 5;
        if (r == 8) return 7;
        if (r == 9) return 8;
        if (r == 10) return 10;
        if (r == 11) return 12;
        break;

      case 'shd':
        if (r <= 19) return 2;
        if (r == 20) return 3;
        if (r == 21) return 4;
        if (r == 22) return 6;
        if (r == 23) return 7;
        if (r == 24) return 9;
        if (r == 25) return 10;
        if (r == 26) return 12;
        if (r == 27) return 13;
        break;

      case 'rl':
        if (r <= 2) return 1;
        if (r == 3) return 4;
        if (r == 4) return 8;
        if (r == 5) return 11;
        break;

      case 'el':
        if (r <= 7) return 5;
        if (r == 8) return 11;
        break;

      case 'cd':
        if (r <= 9) return 1;
        if (r == 10) return 2;
        if (r == 11) return 3;
        if (r == 12) return 4;
        if (r == 13) return 5;
        if (r == 14) return 6;
        if (r == 15) return 7;
        if (r == 16) return 8;
        if (r == 17) return 9;
        if (r == 18) return 10;
        if (r == 19) return 11;
        if (r == 20) return 12;
        if (r == 21) return 13;
        break;

      case 'sed':
        if (r <= 15) return 1;
        if (r == 16) return 2;
        if (r == 17) return 3;
        if (r == 18) return 5;
        if (r == 19) return 6;
        if (r == 20) return 7;
        if (r == 21) return 9;
        if (r == 22) return 10;
        if (r == 23) return 11;
        if (r == 24) return 13;
        break;
    }
    return 0;
  }

  // SCALED INTERPRETATION
  static String _scaledInterpretation(int ss) {
    if (ss <= 3) return "SSDD";
    if (ss <= 6) return "SSLDD";
    if (ss <= 13) return "AD";
    if (ss <= 16) return "SSAD";
    return "SHAD";
  }


  // STANDARD SCORE TABLE
  static int _getStandardScore(int sum) {
    const table = {
      29: 37, 30: 38, 31: 40, 32: 41, 33: 43, 34: 44, 35: 45,
      36: 47, 37: 48, 38: 50, 39: 51, 40: 53, 41: 54, 42: 56,
      43: 57, 44: 59, 45: 60, 46: 62, 47: 63, 48: 65, 49: 66,
      50: 67, 51: 69, 52: 70, 53: 72, 54: 73, 55: 75, 56: 76,
      57: 78, 58: 79, 59: 81, 60: 82, 61: 84, 62: 85, 63: 86,
      64: 88, 65: 89, 66: 91, 67: 92, 68: 94, 69: 95, 70: 97,
      71: 98, 72: 100, 73: 101, 74: 103, 75: 104, 76: 105,
      77: 107, 78: 108, 79: 110, 80: 111, 81: 113, 82: 114,
      83: 116, 84: 117, 85: 119, 86: 120, 87: 122, 88: 123,
      89: 124, 90: 126, 91: 127, 92: 129, 93: 130, 94: 132,
      95: 133, 96: 135, 97: 136, 98: 138,
    };

    return table[sum] ?? 0;
  }


  // OVERALL INTERPRETATION
  static String _overallInterpretation(int score) {
    if (score <= 69) {
      return "SSDD";
    }
    if (score <= 79) {
      return "SSLDD";
    }
    if (score <= 119) {
      return "AD";
    }
    if (score <= 129) {
      return "SSAD";
    }
    return "SHAD";
  }
}