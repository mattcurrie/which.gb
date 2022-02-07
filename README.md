# which.gb

Just a little Game Boy ROM which tries to determine which model/revision your device is.  

It makes use of register values at boot, "extra OAM" differences, PPU quirks, APU quirks, and OAM DMA bus conflicts that differ between device revisions.

## Limitations

It might not be perfect. Let me know if your device is detected incorrectly!

Currently it cannot discern between all SoC revisions. Devices will be reported as one of the following:

- DMG-CPU
- DMG-CPU A/B/C
- CPU MGB
- SGB-CPU 01
- CPU SGB2
- CPU CGB
- CPU CGB A
- CPU CGB B
- CPU CGB C
- CPU CGB D
- CPU CGB E
- CPU AGB 0/A/A E
- CPU AGB B/B E

## Release Notes

v0.4

- Use an OAM DMA bus conflict to discern between devices with CPU CGB A and CPU CGB B revision SOCs. Thanks to [LIJI32](https://github.com/LIJI32/) for discovering this!

v0.3

- Use VRAM reads at the transition from PPU mode 3 to mode 0 discern between devices with CPU AGB 0/A/A E (AGB and GB Player) and CPU AGB B/B E (AGS) revisions

v0.2.2

- Discern between CPU CGB 0/A/B/C, CPU CGB D, and CPU CGB E revisions using more simple "extra OAM" test

v0.2.1

- Fix for some "CPU CGB" devices incorrectly reporting as "CPU CGB A/B"

v0.2

- Add support for discerning between CPU CGB A/B and C revisions

## Credits

- Thanks to Lior Halphon (LIJI32) for his research and [SameSuite](https://github.com/LIJI32/SameSuite) test ROMs.
- Thanks to authors of [Gameboy sound hardware](https://gbdev.gg8.se/wiki/articles/Gameboy_sound_hardware) on the Gameboy Development Wiki.
- Thanks to Joonas Javanainen (gekkio) for his [mooneye-gb](https://github.com/Gekkio/mooneye-gb/) test ROMs which document the register values at boot.
- Written by Matt Currie. 

## License

MIT License. See included LICENSE file for details.
