# YAPP Router UVM Verification

This repository contains reusable UVM verification components (UVCs), a YAPP
router RTL design, and an integrated testbench. The UVCs can be developed and
run individually, while the integrated environment connects them to verify the
router.

## Repository layout

| Path | Contents |
| --- | --- |
| `clock_and_reset/` | Clock and reset UVC and demo testbench |
| `yapp/` | YAPP transmitter UVC |
| `channel/` | Channel receiver UVC, demo testbench, and documentation |
| `hbus/` | HBUS master/slave UVC, demo testbench, and documentation |
| `router/` | Router reference model, scoreboard, and UVM environment |
| `router_rtl/` | YAPP router design under test (DUT) |
| `top/` | Integrated router testbench and register-model sources |

Most UVCs keep SystemVerilog source under `sv/` and demo testbench files under
`tb/`. The channel and HBUS packages also include a `docs/` directory.

## Requirements

- Cadence Xcelium (`xrun`) or a compatible Cadence simulator.
- A UVM installation supported by the simulator.
- The `UVMHOME` environment variable set to the UVM library location expected
  by the simulator. The supplied run files pass it using `-uvmhome $UVMHOME`.

The run files and register-model sources are Cadence-oriented. Compatibility
with other simulators has not been verified.

## Running standalone UVC demos

Run each command from the indicated testbench directory so the relative paths
in `run.f` resolve correctly. Set `UVMHOME` before starting the simulator.

```sh
cd clock_and_reset/tb
xrun -f run.f

cd ../../channel/tb
xrun -f run.f

cd ../../hbus/tb
xrun -f run.f
```

The default tests are selected in each `run.f`. The YAPP UVC currently has no
separate standalone demo testbench; it is used by the integrated environment.

## Integrated router testbench

The integrated environment is assembled from the clock/reset, YAPP, HBUS, and
channel UVCs, the router reference-model/scoreboard environment, and the RTL
DUT. Its testbench and register-model sources are in `top/tb/`.

No top-level `run.f` is currently provided. Compile the sources using the
file list and simulator setup appropriate for your Cadence/UVM installation;
the package sources must be compiled before the integrated testbench that
imports them.

## Generated files

Simulator logs, histories, library/build directories, and waveform outputs are
excluded by `.gitignore`. Keep source files, run files, testbench code, and
documentation under version control.
