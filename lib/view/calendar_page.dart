import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/favorito_model.dart';
import '../service/auth_service.dart';
import '../service/sync_service.dart';
import '../theme/app_theme.dart';
import 'buscas/busca_repositorios_page.dart';
import 'details_page.dart';

class CalendarPage extends StatefulWidget {
    const CalendarPage({super.key});

    @override
    State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
    final syncService = SyncService();

    DateTime diaFocado = DateTime.now();
    DateTime diaSelecionado = DateTime.now();
    CalendarFormat formato = CalendarFormat.month;

    // Favoritos agrupados por dia: { dia: [favoritos] }
    Map<DateTime, List<Favorito>> eventos = {};

    @override
    void initState() {
        super.initState();
        carregar();
    }

    Future<void> carregar() async {
        final userId = AuthService().usuario!.uid;
        final lista = await syncService.listarFavoritos(userId);

        final Map<DateTime, List<Favorito>> agrupados = {};
        for (final favorito in lista) {
            final dia = DateTime(
                favorito.criadoEm.year,
                favorito.criadoEm.month,
                favorito.criadoEm.day,
            );
            agrupados.putIfAbsent(dia, () => []).add(favorito);
        }

        if (!mounted) return;
        setState(() => eventos = agrupados);
    }

    List<Favorito> eventosDoDia(DateTime dia) {
        return eventos[DateTime(dia.year, dia.month, dia.day)] ?? [];
    }

    Future<void> favoritarRepositorio() async {
        await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BuscaRepositorios()),
        );
        if (!mounted) return;
        carregar();
    }

    Future<void> abrirDetalhes(Favorito favorito) async {
        await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailsPage(favorito: favorito)),
        );
        carregar();
    }

    @override
    Widget build(BuildContext context) {
        final doDia = eventosDoDia(diaSelecionado);

        return Scaffold(
            appBar: AppBar(title: const Text('Calendário')),
            body: Column(
                children: [
                    TableCalendar<Favorito>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2100, 12, 31),
                        focusedDay: diaFocado,
                        calendarFormat: formato,
                        availableCalendarFormats: const {
                            CalendarFormat.month: 'Mês',
                            CalendarFormat.twoWeeks: '2 semanas',
                            CalendarFormat.week: 'Semana',
                        },
                        eventLoader: eventosDoDia,
                        selectedDayPredicate: (dia) => isSameDay(diaSelecionado, dia),
                        onDaySelected: (selecionado, focado) {
                            setState(() {
                                diaSelecionado = selecionado;
                                diaFocado = focado;
                            });
                        },
                        onFormatChanged: (novoFormato) {
                            setState(() => formato = novoFormato);
                        },
                        onPageChanged: (focado) {
                            diaFocado = focado;
                        },
                        calendarStyle: CalendarStyle(
                            markerDecoration: const BoxDecoration(
                                color: Colors.orangeAccent,
                                shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                            ),
                        ),
                    ),
                    const Divider(),
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                            'Favoritos de ${Favorito.formatarData(diaSelecionado)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                            ),
                        ),
                    ),
                    Expanded(
                        child: doDia.isEmpty
                            ? const Center(child: Text('Nenhum favorito neste dia.'))
                            : ListView.builder(
                                itemCount: doDia.length,
                                itemBuilder: (context, indice) {
                                    final favorito = doDia[indice];
                                    return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        child: ListTile(
                                            title: Text(favorito.nome),
                                            subtitle: Text(favorito.anotacao,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                            trailing: Icon(favorito.synced
                                                ? Icons.cloud_done
                                                : Icons.cloud_off),
                                            onTap: () => abrirDetalhes(favorito),
                                        ),
                                    );
                                },
                            ),
                    ),
                ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: favoritarRepositorio,
                tooltip: 'Favoritar um repositório',
                child: const Icon(Icons.add),
            ),
        );
    }
}
