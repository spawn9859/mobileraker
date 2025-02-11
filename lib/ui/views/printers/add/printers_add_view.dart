import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mobileraker/datasource/websocket_wrapper.dart';
import 'package:stacked/stacked.dart';

import 'printers_add_viewmodel.dart';

class PrintersAdd extends StatelessWidget {
  const PrintersAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PrintersAddViewModel>.reactive(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Add new printer'),
              actions: [
                IconButton(
                    onPressed: model.onFormConfirm,
                    tooltip: 'Add printer',
                    icon: Icon(Icons.save_outlined))
              ],
            ),
            body: FormBuilder(
              key: model.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    _SectionHeader(title: 'General'),
                    FormBuilderTextField(
                      decoration: InputDecoration(
                        labelText: 'Displayname',
                      ),
                      name: 'printerName',
                      initialValue: model.defaultPrinterName,
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)]),
                    ),
                    FormBuilderTextField(
                      decoration: InputDecoration(
                          labelText: 'Printer-Address',
                          hintText: 'Host, IP, or full URL',
                          helperMaxLines: 2,
                          helperText: model.wsUrl?.isNotEmpty ?? false
                              ? 'Resulting WebSocket-URL: ${model.wsUrl}'
                              : '' //TODO
                          ),
                      onChanged: model.onUrlEntered,
                      name: 'printerUrl',
                      // initialValue: model.inputUrl,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        FormBuilderValidators.url(context,
                            protocols: ['ws', 'wss', 'http','https'])
                      ]),
                    ),
                    FormBuilderTextField(
                      decoration: InputDecoration(
                          labelText: 'Moonraker - API Key',
                          helperText: 'Only needed if youre using trusted clients. FluiddPI enforces this!',
                      ),
                      name: 'printerApiKey',
                    ),
                    Divider(),
                    _SectionHeader(title: 'Misc'),
                    InputDecorator(

                      decoration: InputDecoration(
                        labelText: 'Test websocket connection',
                        border: InputBorder.none,
                        errorText: model.wsError,
                        errorMaxLines: 3,

                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.radio_button_on,
                            size: 10,
                            color: model.wsStateColor,
                          ),
                          Spacer(flex: 1),
                          Text('Result: ${model.wsResult}'),
                          Spacer(flex: 30),
                          ElevatedButton(
                              onPressed: (model.data != WebSocketState.connecting)? model.onTestConnectionTap:null,
                              child: Text('Test'))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        viewModelBuilder: () => PrintersAddViewModel());
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
