import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/registro.dart';
import '../../repositories/registros_repository.dart';

class RegistrosScreen extends StatefulWidget {
  const RegistrosScreen({super.key});

  @override
  State<RegistrosScreen> createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends State<RegistrosScreen> {
  final _repo = RegistrosRepository();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();

  List<Registro> _registros = [];
  bool _carregando = true;
  bool _gravando = false;
  int _segundosGravados = 0;
  Timer? _timer;

  // --- Estado do player ---
  Registro? _registroTocando;
  bool _estaTocando = false;
  Duration _posicaoAtual = Duration.zero;
  Duration _duracaoTotal = Duration.zero;

  // --- Busca ---
  final _buscaController = TextEditingController();
  String _termoBusca = '';
  @override
  void initState() {
    super.initState();
    _carregarRegistros();

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _posicaoAtual = pos);
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duracaoTotal = dur);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _estaTocando = false;
          _posicaoAtual = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();

    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarRegistros() async {
    final lista = await _repo.carregar();
    if (mounted) {
      setState(() {
        _registros = lista;
        _carregando = false;
      });
    }
  }

  Future<void> _iniciarGravacao() async {
    try {
      if (!await _audioRecorder.hasPermission()) {
        _mostrarMensagem('Permissão de microfone negada.', erro: true);
        return;
      }

      String caminho = '';
      if (!kIsWeb) {
        final dir = await getTemporaryDirectory();
        caminho =
            '${dir.path}/registro_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      final config = const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _audioRecorder.start(config, path: caminho);

      setState(() {
        _gravando = true;
        _segundosGravados = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() => _segundosGravados++);

        if (_segundosGravados >= 300) {
          _pararGravacao();
        }
      });
    } catch (e) {
      _mostrarMensagem('Erro ao iniciar gravação.', erro: true);
    }
  }

  Future<void> _pararGravacao() async {
    _timer?.cancel();

    try {
      final path = await _audioRecorder.stop();
      setState(() => _gravando = false);

      if (path == null) {
        _mostrarMensagem('Gravação cancelada.', erro: true);
        return;
      }

      if (mounted) {
        await _pedirDadosRegistro(path);
      }
    } catch (e) {
      _mostrarMensagem('Erro ao parar gravação.', erro: true);
    }
  }

  Future<void> _pedirDadosRegistro(String caminhoAudio) async {
    final tituloController = TextEditingController();
    final resumoController = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Salvar Registro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resumoController,
                decoration: const InputDecoration(
                  labelText: 'Resumo',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Descartar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (confirmado == true && tituloController.text.trim().isNotEmpty) {
      final nomeArquivo = caminhoAudio.split(RegExp(r'[/\\]')).last;

      final novoRegistro = Registro(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: tituloController.text.trim(),
        resumo: resumoController.text.trim(),
        nomeArquivoAudio: nomeArquivo,
        dataCriacao: DateTime.now(),
        duracaoSegundos: _segundosGravados,
      );

      final listaAtualizada = [..._registros, novoRegistro];
      await _repo.salvar(listaAtualizada);

      if (mounted) {
        setState(() => _registros = listaAtualizada);
        _mostrarMensagem('Registro salvo com sucesso!');
      }
    }
  }

  Future<void> _editarRegistro(Registro r) async {
    final tituloController = TextEditingController(text: r.titulo);
    final resumoController = TextEditingController(text: r.resumo);

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Registro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resumoController,
                decoration: const InputDecoration(
                  labelText: 'Resumo',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar Alterações'),
          ),
        ],
      ),
    );

    if (confirmado == true && tituloController.text.trim().isNotEmpty) {
      final registroAtualizado = Registro(
        id: r.id,
        titulo: tituloController.text.trim(),
        resumo: resumoController.text.trim(),
        nomeArquivoAudio: r.nomeArquivoAudio,
        dataCriacao: r.dataCriacao,
        duracaoSegundos: r.duracaoSegundos,
      );

      final listaAtualizada = _registros.map((item) {
        return item.id == r.id ? registroAtualizado : item;
      }).toList();

      await _repo.salvar(listaAtualizada);

      if (mounted) {
        setState(() => _registros = listaAtualizada);
        _mostrarMensagem('Registro atualizado com sucesso!');
      }
    }
  }

  Future<void> _tocarRegistro(Registro r) async {
    try {
      if (kIsWeb) {
        _mostrarMensagem('Reprodução na Web requer implementação adicional.',
            erro: true);
        return;
      }

      if (_registroTocando?.id == r.id) {
        if (_estaTocando) {
          await _audioPlayer.pause();
          setState(() => _estaTocando = false);
        } else {
          await _audioPlayer.resume();
          setState(() => _estaTocando = true);
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final caminhoCompleto = '${dir.path}/${r.nomeArquivoAudio}';

      if (File(caminhoCompleto).existsSync()) {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(caminhoCompleto));
        if (mounted) {
          setState(() {
            _registroTocando = r;
            _estaTocando = true;
            _posicaoAtual = Duration.zero;
          });
        }
      } else {
        _mostrarMensagem('Arquivo de Áudio não encontrado.', erro: true);
      }
    } catch (e) {
      _mostrarMensagem('Erro ao tocar Áudio.', erro: true);
    }
  }

  Future<void> _seek(Duration pos) async {
    await _audioPlayer.seek(pos);
    if (mounted) setState(() => _posicaoAtual = pos);
  }

  void _avancar10s() {
    final novaPos = _posicaoAtual + const Duration(seconds: 10);
    _seek(novaPos > _duracaoTotal ? _duracaoTotal : novaPos);
  }

  void _recuar10s() {
    final novaPos = _posicaoAtual - const Duration(seconds: 10);
    _seek(novaPos < Duration.zero ? Duration.zero : novaPos);
  }

  void _fecharPlayer() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _registroTocando = null;
        _estaTocando = false;
        _posicaoAtual = Duration.zero;
        _duracaoTotal = Duration.zero;
      });
    }
  }

  Future<void> _excluirRegistro(Registro r) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Registro'),
        content: Text('Deseja excluir "${r.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    final novaLista = _registros.where((x) => x.id != r.id).toList();
    await _repo.salvar(novaLista);

    if (!kIsWeb) {
      try {
        final dir = await getTemporaryDirectory();
        final caminho = '${dir.path}/${r.nomeArquivoAudio}';
        if (File(caminho).existsSync()) {
          await File(caminho).delete();
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _registros = novaLista);
      _mostrarMensagem('Registro excluído.');
    }
  }

  void _mostrarMensagem(String msg, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  String _formatarTempo(int seg) {
    final m = (seg ~/ 60).toString().padLeft(2, '0');
    final s = (seg % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildListaFiltrada() {
    final filtrados = _registros.where((r) {
      if (_termoBusca.isEmpty) return true;
      return r.titulo.toLowerCase().contains(_termoBusca) ||
          r.resumo.toLowerCase().contains(_termoBusca);
    }).toList();

    if (filtrados.isEmpty) {
      return const Center(child: Text('Nenhum registro encontrado.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtrados.length,
      itemBuilder: (ctx, i) {
        final r = filtrados[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.audiotrack, size: 32),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    r.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatarTempo(r.duracaoSegundos),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            subtitle: Text(r.resumo.isEmpty ? 'Sem resumo' : r.resumo),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _registroTocando?.id == r.id && _estaTocando
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.green,
                  ),
                  onPressed: () => _tocarRegistro(r),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editarRegistro(r),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _excluirRegistro(r),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatarDuracao(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registros de Áudio')),
      bottomNavigationBar: _carregando
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _gravando ? _pararGravacao : _iniciarGravacao,
                    icon: Icon(_gravando ? Icons.stop : Icons.mic),
                    label: Text(
                      _gravando ? 'Parar Gravação' : 'Iniciar Gravação',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gravando ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ---- INFORMAÇÕES E CRONÔMETRO ----
                Container(
                  padding: const EdgeInsets.all(24),
                  color: _gravando ? Colors.red.shade50 : Colors.blue.shade50,
                  child: Column(
                    children: [
                      Text(
                        _gravando
                            ? _formatarTempo(_segundosGravados)
                            : 'Anote suas ideias, registre informações e grave os momentos importantes da sua campanha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _gravando ? 32 : 14,
                          fontWeight:
                              _gravando ? FontWeight.bold : FontWeight.normal,
                          color: _gravando ? Colors.red : Colors.black87,
                        ),
                      ),
                      if (_gravando)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Limite: 5 minutos',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // ---- PLAYER FIXO ----
                if (_registroTocando != null)
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _registroTocando!.titulo,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _fecharPlayer,
                              ),
                            ],
                          ),
                          Slider(
                            value: _posicaoAtual.inSeconds
                                .toDouble()
                                .clamp(0, _duracaoTotal.inSeconds.toDouble()),
                            min: 0,
                            max: _duracaoTotal.inSeconds > 0
                                ? _duracaoTotal.inSeconds.toDouble()
                                : 1,
                            onChanged: (v) =>
                                _seek(Duration(seconds: v.toInt())),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10),
                                onPressed: _recuar10s,
                              ),
                              IconButton(
                                icon: Icon(_estaTocando
                                    ? Icons.pause
                                    : Icons.play_arrow),
                                iconSize: 36,
                                onPressed: () =>
                                    _tocarRegistro(_registroTocando!),
                              ),
                              IconButton(
                                icon: const Icon(Icons.forward_10),
                                onPressed: _avancar10s,
                              ),
                            ],
                          ),
                          Text(
                            '${_formatarDuracao(_posicaoAtual)} / ${_formatarDuracao(_duracaoTotal)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ---- BUSCADOR ----
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TextField(
                    controller: _buscaController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por título ou resumo',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        setState(() => _termoBusca = v.trim().toLowerCase()),
                  ),
                ),
                Expanded(
                  child: _buildListaFiltrada(),
                ),
              ],
            ),
    );
  }
}
