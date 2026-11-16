---
name: Fresh Clean Glass
colors:
  surface: '#FFFFFF'
  surface-dim: '#d0dbeb'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eef4ff'
  surface-container: '#e4efff'
  surface-container-high: '#dee9fa'
  surface-container-highest: '#d8e3f4'
  on-surface: '#111c28'
  on-surface-variant: '#3f484c'
  inverse-surface: '#26313e'
  inverse-on-surface: '#e9f1ff'
  outline: '#6f797c'
  outline-variant: '#bfc8cc'
  surface-tint: '#11677c'
  primary: '#005669'
  on-primary: '#ffffff'
  primary-container: '#1f6f84'
  on-primary-container: '#bbedff'
  inverse-primary: '#8ad1e8'
  secondary: '#845400'
  on-secondary: '#ffffff'
  secondary-container: '#fcaa2c'
  on-secondary-container: '#6a4300'
  tertiary: '#991c15'
  on-tertiary: '#ffffff'
  tertiary-container: '#bb362a'
  on-tertiary-container: '#ffded9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b3ebff'
  primary-fixed-dim: '#8ad1e8'
  on-primary-fixed: '#001f27'
  on-primary-fixed-variant: '#004e5f'
  secondary-fixed: '#ffddb6'
  secondary-fixed-dim: '#ffb95a'
  on-secondary-fixed: '#2a1800'
  on-secondary-fixed-variant: '#643f00'
  tertiary-fixed: '#ffdad5'
  tertiary-fixed-dim: '#ffb4a9'
  on-tertiary-fixed: '#410001'
  on-tertiary-fixed-variant: '#8e130e'
  background: '#f8f9ff'
  on-background: '#111c28'
  surface-variant: '#d8e3f4'
  ink-950: '#0E0F11'
  ink-800: '#1C2733'
  slate-500: '#5E7384'
  slate-700: '#4B5B6A'
  slate-400: '#8296A8'
  slate-100: '#E8EDF2'
  text-secondary: '#5F6873'
  text-disabled: '#8B94A0'
  canvas: '#EEF3F7'
  sky-top: '#C3D6E6'
  sky-mid: '#DCE8F0'
  peach-glow: '#F6EAE2'
  teal-100: '#DCEEF3'
  teal-500: '#3E9AB0'
  teal-600: '#2B7F94'
  teal-700: '#1F6F84'
  amber-100: '#FCEFD4'
  amber-500: '#F0A020'
  amber-700: '#8A5200'
  red-100: '#FCE4E1'
  red-500: '#EF5B4B'
  red-600: '#C5332B'
  red-700: '#B3261E'
  dotted-border: '#B8C4CE'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

# Design System: Laundry App

Mobile-first design spec for the customer, clerk and owner apps described in the PRD (v1.0) and `laundry_schema.sql`.

:root {
  --ink-950: #0E0F11;
  --ink-800: #1C2733;
  --slate-500: #5E7384;
  --text-secondary: #5F6873;
  --text-disabled: #8B94A0;
  --canvas: #EEF3F7;
  --sky-top: #C3D6E6;
  --sky-mid: #DCE8F0;
  --peach-glow: #F6EAE2;
  --surface: #FFFFFF;
  --glass: rgba(255,255,255,0.66);
  --glass-strong: rgba(255,255,255,0.82);
  --glass-border: rgba(255,255,255,0.70);
  --hairline: rgba(14,15,17,0.08);
  --dotted: #B8C4CE;

  --teal-100: #DCEEF3;
  --teal-500: #3E9AB0;
  --teal-600: #2B7F94;
  --teal-700: #1F6F84;
  --amber-100: #FCEFD4;
  --amber-500: #F0A020;
  --amber-700: #8A5200;
  --red-100: #FCE4E1;
  --red-500: #EF5B4B;
  --red-600: #C5332B;
  --red-700: #B3261E;
  --slate-100: #E8EDF2;
  --slate-400: #8296A8;
  --slate-700: #4B5B6A;

  --r-8: 8px;
  --r-12: 12px;
  --r-16: 16px;
  --r-20: 20px;
  --r-28: 28px;
  --r-pill: 999px;

  --s-1: 4px;
  --s-2: 8px;
  --s-3: 12px;
  --s-4: 16px;
  --s-5: 20px;
  --s-6: 24px;
  --s-8: 32px;
  --s-10: 40px;
  --s-14: 56px;

  --blur-glass: blur(24px) saturate(1.3);
  --shadow-card: 0 10px 30px rgba(28,39,51,0.08);
  --shadow-float: 0 16px 40px rgba(28,39,51,0.16);

  --font: "Inter Tight", "Inter", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
}
