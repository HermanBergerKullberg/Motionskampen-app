import 'package:flutter/material.dart';
import 'package:moveness/app_theme.dart';
import 'package:moveness/dtos/requests/challenge_private.dart';
import 'package:moveness/dtos/requests/challenge_team.dart';
import 'package:moveness/locator.dart';
import 'package:moveness/providers/search.dart';
import 'package:moveness/services/api.dart';
import 'package:moveness/misc/error_dialogs.dart';
import 'package:moveness/shared/heading.dart';
import 'package:moveness/shared/ok_dialog.dart';
import 'package:moveness/shared/search_user_team.dart';
import 'package:provider/provider.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage(this.searchUser, {this.teamId, Key? key})
      : super(key: key);
  final bool searchUser;
  final int? teamId;

  @override
  _CreateChallengePageState createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _api = locator<ApiService>();
  bool _isChallengeButtonDisabled = false;
  bool _isRandomButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.clear();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(title: Text('Skapa utmaning')),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                ThemeSettings.getMainPadding(),
                0,
                ThemeSettings.getMainPadding(),
              ),
              child: RaisedButton(
                onPressed: _isRandomButtonDisabled
                    ? null
                    : () async {
                        setState(() {
                          _isRandomButtonDisabled = true;
                        });

                        if (widget.searchUser) {
                          var response = await _api.challengeRandomUser();

                          if (response.isSuccess()) {
                            Navigator.of(context).pop();

                            showDialog(
                              context: context,
                              builder: (context) => OkDialog(
                                title: "Inbjudan lyckades!",
                                buttonText: "Ok",
                                content: "N??gon har f??tt en utmaning.",
                              ),
                            );
                          } else {
                            setState(() {
                              _isRandomButtonDisabled = false;
                            });

                            ErrorDialogs(response, context).show();
                          }
                        } else {
                          var request = ChallengeTeamRequest(
                            challengingTeamId: widget.teamId,
                          );

                          var response = await _api.challengeTeam(request);

                          if (response.isSuccess()) {
                            Navigator.of(context).pop();

                            showDialog(
                              context: context,
                              builder: (context) => OkDialog(
                                title: "Lyckades",
                                buttonText: "Ok",
                                content: "Ett team har f??tt en utmaning.",
                              ),
                            );
                          } else {
                            setState(() {
                              _isChallengeButtonDisabled = false;
                            });

                            ErrorDialogs(response, context).show();
                          }
                        }
                      },
                child: Text("Utmana slumpm??ssig"),
              ),
            ),
            SizedBox(height: ThemeSettings.getMainPadding()),
            Heading(
                widget.searchUser
                    ? "Eller s??k efter anv??ndare"
                    : "Eller s??k efter team",
                ThemeSettings.textColor),
            SearchUserTeam(widget.searchUser, false),
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                ThemeSettings.getMainPadding(),
                0,
                ThemeSettings.getMainPadding(),
              ),
              child: RaisedButton(
                onPressed: _isChallengeButtonDisabled
                    ? null
                    : () async {
                        if (widget.searchUser) {
                          var users = searchProvider.selectedUsers;

                          if (users!.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => OkDialog(
                                title: "Ingen anv??ndare",
                                content:
                                    "Du m??ste v??lja en anv??ndare att utmana",
                                buttonText: "Ok",
                              ),
                            );

                            return;
                          }

                          setState(() {
                            _isChallengeButtonDisabled = true;
                          });

                          var user = users.first;

                          var request = ChallengeUserRequest(
                            challengedId: user.id,
                          );

                          var response = await _api.challengeUser(request);

                          if (response.isSuccess()) {
                            Navigator.of(context).pop();

                            showDialog(
                              context: context,
                              builder: (context) => OkDialog(
                                title: "Inbjudan lyckades!",
                                buttonText: "Ok",
                                content:
                                    "${user.username} har f??tt en utmaning.",
                              ),
                            );
                          } else {
                            setState(() {
                              _isChallengeButtonDisabled = false;
                            });

                            ErrorDialogs(response, context).show();
                          }
                        } else {
                          var team = searchProvider.selectedTeam;

                          //Manual validation
                          if (team == null) {
                            showDialog(
                              context: context,
                              builder: (context) => OkDialog(
                                title: "Ingen team valt",
                                content: "Du m??ste v??lja ett team att utamana.",
                                buttonText: "Ok",
                              ),
                            );

                            return;
                          }

                          setState(() {
                            _isChallengeButtonDisabled = true;
                          });

                          var request = ChallengeTeamRequest(
                            challengingTeamId: widget.teamId,
                            challengedTeamId: team.id,
                          );

                          var response = await _api.challengeTeam(request);

                          if (response.isSuccess()) {
                            Navigator.of(context).pop();

                            showDialog(
                              context: context,
                              builder: (context) => OkDialog(
                                title: "Lyckades",
                                buttonText: "Ok",
                                content: "${team.name} har f??tt en utmaning.",
                              ),
                            );
                          } else {
                            setState(() {
                              _isChallengeButtonDisabled = false;
                            });

                            ErrorDialogs(response, context).show();
                          }
                        }
                      },
                child: Text('Utmana'),
              ),
            ),
          ],
        ));
  }
}
