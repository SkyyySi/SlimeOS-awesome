# Creating new awesome widgets

## Summary

A basic guide on how to make your own awesome wm widgets.

## Description

The best part about awesome wm is most certainly it's widget system.
It is extremely flexible and even allows to use the power of Cairo
to render fast, custom graphics from scratch. However, it can also
be quite tough to wrap your head around when getting started.
This document will guide you through the process of creating your very
own widgets. Please note that this can be concidered 'advanced', as
you will most likely be writing quite a bit of lua code. But don't worry:
This guide was created for people with little lua experience or expeiance
with GUI coding in general.

## Some good things to know from the start

* Awesome's widget system is, in many ways, quite similar to web technologies,
in the sense that it borrows many design patterns from HTML and CSS. For example,
the design properties are cascading, and the layout system is also very
similar to CSS, with things like the [CSS Box Model](https://www.w3schools.com/css/css_boxmodel.asp)
or the layout system with things like [flexbox](https://www.w3schools.com/css/css3_flexbox.asp)
or [grid](https://www.w3schools.com/css/css_grid.asp) layouts.
It may thus be useful to you to read up on these.


