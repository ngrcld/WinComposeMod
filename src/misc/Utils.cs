//
//  WinCompose — a compose key for Windows — http://wincompose.info/
//
//  Copyright © 2013—2020 Sam Hocevar <sam@hocevar.net>
//
//  This program is free software. It comes without any warranty, to
//  the extent permitted by applicable law. You can redistribute it
//  and/or modify it under the terms of the Do What the Fuck You Want
//  to Public License, Version 2, as published by the WTFPL Task Force.
//  See http://www.wtfpl.net/ for more details.
//

using System;
using System.IO;
using System.Reflection;

namespace WinCompose
{
    static class Utils
    {
        public static bool EnsureDirectory(string directory)
        {
            try
            {
                Directory.CreateDirectory(directory);
                return true;
            }
            catch (Exception ex)
            {
                Log.Debug($"Could not create {directory}: {ex}");
                return false;
            }
        }

        public static string DataDir
            => Path.GetDirectoryName(Uri.UnescapeDataString(new UriBuilder(Assembly.GetExecutingAssembly().GetName().CodeBase).Path));
    }
}

