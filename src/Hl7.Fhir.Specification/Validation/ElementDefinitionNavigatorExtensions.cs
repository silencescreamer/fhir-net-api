/* 
 * Copyright (c) 2016, Furore (info@furore.com) and contributors
 * See the file CONTRIBUTORS for details.
 * 
 * This file is licensed under the BSD 3-Clause license
 * available at https://raw.githubusercontent.com/ewoutkramer/fhir-net-api/master/LICENSE
 */

using System;
using System.Linq;
using Hl7.Fhir.Model;
using Hl7.Fhir.Specification.Navigation;

namespace Hl7.Fhir.Validation
{

    internal static class ElementDefinitionNavigatorExtensions
    {
        public static string GetFhirPathConstraint(this ElementDefinition.ConstraintComponent cc)
        {
            // This was required for 3.0.0, but was rectified in the 3.0.1 technical update
            //if (cc.Key == "ele-1")
            //    return "(children().count() > id.count()) | hasValue()";
            return cc.Expression;
        }


//#if NETSTANDARD1_1
//        public static int Count(this string s, Func<char, bool> predicate)
//        {
//            return s.ToCharArray().Where(predicate).Count();
//        }
//#endif

        public static bool IsPrimitiveValueConstraint(this ElementDefinition ed)
        {
            var path = ed.Path;

            return path.Count(c => c == '.') == 1 &&
                        path.EndsWith(".value") &&
                        Char.IsLower(path[0]);
        }

        public static string ConstraintDescription(this ElementDefinition.ConstraintComponent cc)
        {
            var desc = cc.Key;

            if (cc.Human != null)
                desc += " \"" + cc.Human + "\"";

            return desc;
        }


        public static string QualifiedDefinitionPath(this ElementDefinitionNavigator nav)
        {
            string path = "";

            if (nav.StructureDefinition != null && nav.StructureDefinition.Url != null)
                path = "{" + nav.StructureDefinition.Url + "}";

            path += nav.Path;

            return path;
        }
    }

}